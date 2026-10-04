"""Build one account's GPU cost workbook and email it."""

import io
import os
import re
from collections import defaultdict
from datetime import datetime
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from zoneinfo import ZoneInfo

import boto3
from openpyxl import Workbook
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.utils import get_column_letter

COST_METRIC = "NetAmortizedCost"
COST_LABEL = "Net Amortized Cost"
SERVICE = "Amazon Elastic Compute Cloud - Compute"
IST = ZoneInfo("Asia/Kolkata")

GPU_PATTERN = re.compile(
    r"BoxUsage:((?:p[2-5](?:en)?|g[3-7](?:e|f|g)?|inf[12]|trn[12]|dl1|f[12])\.[a-z0-9]+)",
    re.I,
)

GPU_INFO = {
    "p5.48xlarge": "NVIDIA H100 (8 GPUs)",
    "p5en.48xlarge": "NVIDIA H200 (8 GPUs)",
    "p5.4xlarge": "NVIDIA H100 (1 GPU)",
    "g4dn.xlarge": "NVIDIA T4 (1 GPU)",
    "g5.xlarge": "NVIDIA A10G (1 GPU)",
    "g5.4xlarge": "NVIDIA A10G (1 GPU)",
    "g5.12xlarge": "NVIDIA A10G (4 GPUs)",
    "g6.xlarge": "NVIDIA L4 (1 GPU)",
    "g6.2xlarge": "NVIDIA L4 (1 GPU)",
    "g6.12xlarge": "NVIDIA L4 (4 GPUs)",
    "g6e.xlarge": "NVIDIA L40S (1 GPU)",
    "g6e.2xlarge": "NVIDIA L40S (1 GPU)",
    "g6e.4xlarge": "NVIDIA L40S (1 GPU)",
    "g6e.12xlarge": "NVIDIA L40S (4 GPUs)",
    "g6e.24xlarge": "NVIDIA L40S (4 GPUs)",
    "g6e.48xlarge": "NVIDIA L40S (8 GPUs)",
    "g7e.2xlarge": "NVIDIA L40S (1 GPU)",
    "g7e.4xlarge": "NVIDIA L40S (1 GPU)",
    "g7e.12xlarge": "NVIDIA L40S (4 GPUs)",
    "g7e.24xlarge": "NVIDIA L40S (4 GPUs)",
    "g7e.48xlarge": "NVIDIA L40S (8 GPUs)",
}

REGION_MAP = {
    "USW2": "us-west-2",
    "USE1": "us-east-1",
    "USE2": "us-east-2",
    "EUC1": "eu-central-1",
    "EUW2": "eu-west-2",
    "APN1": "ap-northeast-1",
}

GPU_INSTANCE_TYPES = [
    "p2.xlarge", "p2.8xlarge", "p2.16xlarge", "p3.2xlarge", "p3.8xlarge", "p3.16xlarge",
    "p4d.24xlarge", "p4de.24xlarge", "p5.4xlarge", "p5.48xlarge", "p5en.48xlarge",
    "g3s.xlarge", "g3.4xlarge", "g3.8xlarge", "g3.16xlarge",
    "g4dn.xlarge", "g4dn.2xlarge", "g4dn.4xlarge", "g4dn.8xlarge", "g4dn.12xlarge", "g4dn.16xlarge",
    "g5.xlarge", "g5.2xlarge", "g5.4xlarge", "g5.8xlarge", "g5.12xlarge", "g5.16xlarge", "g5.24xlarge", "g5.48xlarge",
    "g6.xlarge", "g6.2xlarge", "g6.4xlarge", "g6.8xlarge", "g6.12xlarge", "g6.16xlarge", "g6.24xlarge", "g6.48xlarge",
    "g6e.xlarge", "g6e.2xlarge", "g6e.4xlarge", "g6e.8xlarge", "g6e.12xlarge", "g6e.16xlarge", "g6e.24xlarge", "g6e.48xlarge",
    "g7.xlarge", "g7.2xlarge", "g7.4xlarge", "g7.8xlarge", "g7.12xlarge", "g7.16xlarge", "g7.24xlarge", "g7.48xlarge",
    "g7e.2xlarge", "g7e.4xlarge", "g7e.8xlarge", "g7e.12xlarge", "g7e.24xlarge", "g7e.48xlarge",
    "inf1.xlarge", "inf1.2xlarge", "inf1.6xlarge", "inf1.24xlarge",
    "inf2.xlarge", "inf2.8xlarge", "inf2.24xlarge", "inf2.48xlarge",
    "trn1.2xlarge", "trn1.32xlarge", "trn2.48xlarge", "dl1.24xlarge",
]

PRODUCT_MAP = {
    "ai-canvas": "AI Canvas",
    "AI-Dev-Studio": "AI Canvas / Dev Studio",
    "ai-defense": "AI Defense",
    "ai-defence": "AI Defense",
    "ai-defense-hybrid": "AI Defense Hybrid",
    "ai-assistant": "AI Assistant",
    "ai": "Kubeflow / ML Platform",
    "NeuralFabric": "Neural Fabric",
    "cisco-dnm": "DNM",
    "c3": "C3",
    "freeplay-ai-byoc": "Freeplay",
    "freeplay-ai": "Freeplay",
    "": "Untagged",
}

HEADER_FILL = PatternFill("solid", fgColor="00529B")
HEADER_FONT = Font(bold=True, color="FFFFFF")
TITLE_FONT = Font(bold=True, size=14, color="00529B")
USD_NUMBER_FORMAT = "$#,##0"


def round_usd(value):
    return int(round(value))


def fmt_usd(value):
    rounded = round_usd(value)
    if rounded < 0:
        return f"-${abs(rounded):,}"
    return f"${rounded:,}"


def fmt_hours(value):
    return f"{int(round(value)):,}"


def fmt_pct(value):
    if value is None:
        return "n/a"
    sign = "+" if value > 0 else ""
    return f"{sign}{value:.1f}%"


def parse_usage_type(usage_type):
    match = GPU_PATTERN.search(usage_type)
    if not match:
        return None, None
    instance_type = match.group(1).lower()
    if "-BoxUsage:" in usage_type:
        prefix = usage_type.split("-BoxUsage:")[0]
        return instance_type, REGION_MAP.get(prefix, prefix)
    if usage_type.startswith("BoxUsage:"):
        return instance_type, "us-east-1"
    return instance_type, None


def canonical_product(raw_key):
    raw = raw_key.replace("Product$", "").strip()
    return PRODUCT_MAP.get(raw, raw or "Untagged")


def two_complete_months(now):
    first_of_this_month = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    current_start = (first_of_this_month.replace(day=1) - _one_day(first_of_this_month)).replace(day=1)
    prior_start = (current_start - _one_day(current_start)).replace(day=1)
    periods = []
    for start, end in ((prior_start, current_start), (current_start, first_of_this_month)):
        periods.append(
            {
                "label": start.strftime("%B %Y"),
                "short": start.strftime("%b"),
                "word": start.strftime("%B"),
                "start": start.strftime("%Y-%m-%d"),
                "end": end.strftime("%Y-%m-%d"),
            }
        )
    return periods[0], periods[1]


def _one_day(day):
    from datetime import timedelta

    return timedelta(days=1)


def cost_pages(ce, **kwargs):
    token = None
    groups = []
    while True:
        if token:
            kwargs["NextPageToken"] = token
        page = ce.get_cost_and_usage(**kwargs)
        for period in page.get("ResultsByTime", []):
            groups.extend(period.get("Groups", []))
        token = page.get("NextPageToken")
        if not token:
            return groups


def load_usage(ce, prior, current):
    results = {}
    for period in (prior, current):
        by_type = defaultdict(lambda: {"unblended": 0.0, "net_amortized": 0.0, "hours": 0.0, "regions": set()})
        by_region = defaultdict(lambda: {"unblended": 0.0, "net_amortized": 0.0, "hours": 0.0})
        groups = cost_pages(
            ce,
            TimePeriod={"Start": period["start"], "End": period["end"]},
            Granularity="MONTHLY",
            Metrics=["UnblendedCost", COST_METRIC, "UsageQuantity"],
            GroupBy=[{"Type": "DIMENSION", "Key": "USAGE_TYPE"}],
            Filter={"Dimensions": {"Key": "SERVICE", "Values": [SERVICE]}},
        )
        for group in groups:
            instance_type, region = parse_usage_type(group["Keys"][0])
            if not instance_type:
                continue
            metrics = group["Metrics"]
            unblended = float(metrics["UnblendedCost"]["Amount"])
            net = float(metrics[COST_METRIC]["Amount"])
            hours = float(metrics["UsageQuantity"]["Amount"])
            by_type[instance_type]["unblended"] += unblended
            by_type[instance_type]["net_amortized"] += net
            by_type[instance_type]["hours"] += hours
            if region:
                by_type[instance_type]["regions"].add(region)
                regional = by_region[(instance_type, region)]
                regional["unblended"] += unblended
                regional["net_amortized"] += net
                regional["hours"] += hours
        rows = []
        for instance_type, values in sorted(by_type.items(), key=lambda item: -item[1]["net_amortized"]):
            if values["net_amortized"] < 0.01 and values["hours"] < 0.01:
                continue
            rows.append(
                {
                    "instance_type": instance_type,
                    "gpu": GPU_INFO.get(instance_type, "GPU instance"),
                    "hours": values["hours"],
                    "net_amortized": values["net_amortized"],
                    "unblended": values["unblended"],
                    "regions": ", ".join(sorted(values["regions"])),
                }
            )
        results[period["label"]] = {
            "rows": rows,
            "total_net_amortized": sum(row["net_amortized"] for row in rows),
            "total_unblended": sum(row["unblended"] for row in rows),
            "total_hours": sum(row["hours"] for row in rows),
            "by_region": [
                {
                    "instance_type": key[0],
                    "region": key[1],
                    "hours": values["hours"],
                    "net_amortized": values["net_amortized"],
                    "unblended": values["unblended"],
                }
                for key, values in sorted(by_region.items(), key=lambda item: -item[1]["net_amortized"])
                if values["net_amortized"] >= 0.01 or values["hours"] >= 0.01
            ],
        }
    return results


def load_tags(ce, prior, current):
    results = {}
    for period in (prior, current):
        filt = {
            "And": [
                {"Dimensions": {"Key": "SERVICE", "Values": [SERVICE]}},
                {"Dimensions": {"Key": "INSTANCE_TYPE", "Values": GPU_INSTANCE_TYPES}},
            ]
        }
        product_groups = cost_pages(
            ce,
            TimePeriod={"Start": period["start"], "End": period["end"]},
            Granularity="MONTHLY",
            Metrics=[COST_METRIC, "UsageQuantity"],
            Filter=filt,
            GroupBy=[{"Type": "TAG", "Key": "Product"}],
        )
        by_product = defaultdict(lambda: {"net_amortized": 0.0, "hours": 0.0})
        for group in product_groups:
            product = canonical_product(group["Keys"][0])
            by_product[product]["net_amortized"] += float(group["Metrics"][COST_METRIC]["Amount"])
            by_product[product]["hours"] += float(group["Metrics"]["UsageQuantity"]["Amount"])
        rows = [
            {"product": name, "net_amortized": values["net_amortized"], "hours": values["hours"]}
            for name, values in sorted(by_product.items(), key=lambda item: -item[1]["net_amortized"])
            if values["net_amortized"] >= 1
        ]
        cluster_groups = cost_pages(
            ce,
            TimePeriod={"Start": period["start"], "End": period["end"]},
            Granularity="MONTHLY",
            Metrics=[COST_METRIC, "UsageQuantity"],
            Filter=filt,
            GroupBy=[{"Type": "TAG", "Key": "aws:eks:cluster-name"}],
        )
        clusters = []
        for group in cluster_groups:
            name = group["Keys"][0].replace("aws:eks:cluster-name$", "") or "untagged"
            net = float(group["Metrics"][COST_METRIC]["Amount"])
            hours = float(group["Metrics"]["UsageQuantity"]["Amount"])
            if net >= 1:
                clusters.append({"cluster": name, "net_amortized": net, "hours": hours})
        clusters.sort(key=lambda item: -item["net_amortized"])
        results[period["label"]] = {"rows": rows, "clusters": clusters[:15]}
    return results


def style_header_row(ws, row, col_count):
    for col in range(1, col_count + 1):
        cell = ws.cell(row=row, column=col)
        cell.fill = HEADER_FILL
        cell.font = HEADER_FONT
        cell.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)


def write_table(ws, start_row, headers, rows, number_cols=None, usd_cols=None):
    if number_cols is None:
        number_cols = set(range(2, len(headers) + 1))
    if usd_cols is None:
        usd_cols = set()
    for col, header in enumerate(headers, start=1):
        ws.cell(row=start_row, column=col, value=header)
    style_header_row(ws, start_row, len(headers))
    for offset, row in enumerate(rows, start=1):
        for col, value in enumerate(row, start=1):
            if col in usd_cols and isinstance(value, (int, float)):
                value = round_usd(value)
            cell = ws.cell(row=start_row + offset, column=col, value=value)
            if col in number_cols:
                cell.alignment = Alignment(horizontal="right")
            if col in usd_cols:
                cell.number_format = USD_NUMBER_FORMAT
    return start_row + len(rows) + 2


def autosize_columns(ws):
    for col in range(1, ws.max_column + 1):
        letter = get_column_letter(col)
        width = 10
        for cell in ws[letter]:
            if cell.value is not None:
                width = max(width, min(len(str(cell.value)) + 2, 48))
        ws.column_dimensions[letter].width = width


def comparison_rows(results, prior, current):
    prior_rows = {row["instance_type"]: row for row in results[prior["label"]]["rows"]}
    current_rows = {row["instance_type"]: row for row in results[current["label"]]["rows"]}
    names = sorted(
        set(prior_rows) | set(current_rows),
        key=lambda name: -max(
            current_rows.get(name, prior_rows.get(name, {"net_amortized": 0}))["net_amortized"],
            prior_rows.get(name, {"net_amortized": 0})["net_amortized"],
        ),
    )
    rows = []
    for name in names:
        before = prior_rows.get(name, {"hours": 0, "net_amortized": 0, "gpu": GPU_INFO.get(name, "GPU instance")})
        after = current_rows.get(name, {"hours": 0, "net_amortized": 0, "gpu": GPU_INFO.get(name, "GPU instance")})
        if before["net_amortized"] < 1 and after["net_amortized"] < 1 and before["hours"] < 1 and after["hours"] < 1:
            continue
        delta = after["net_amortized"] - before["net_amortized"]
        pct = (delta / before["net_amortized"] * 100) if before["net_amortized"] else None
        rows.append([name, before.get("gpu") or after.get("gpu"), before["hours"], after["hours"], before["net_amortized"], after["net_amortized"], delta, pct])
    return rows


def build_workbook(account, account_label, prior, current, results, products, generated_at):
    prior_total = results[prior["label"]]
    current_total = results[current["label"]]
    delta_net = current_total["total_net_amortized"] - prior_total["total_net_amortized"]
    delta_pct = (delta_net / prior_total["total_net_amortized"] * 100) if prior_total["total_net_amortized"] else 0
    delta_hours = current_total["total_hours"] - prior_total["total_hours"]
    hours_pct = (delta_hours / prior_total["total_hours"] * 100) if prior_total["total_hours"] else 0

    wb = Workbook()
    ws = wb.active
    ws.title = "Summary"
    ws["A1"] = "AWS GPU Cost Report"
    ws["A1"].font = TITLE_FONT
    ws["A2"] = account_label
    ws["A3"] = f"AWS Account: {account}"
    ws["A4"] = f"Comparison Period: {prior['label']} vs {current['label']}"
    ws["A5"] = f"Cost metric: {COST_LABEL}"
    ws["A6"] = f"Generated: {generated_at}"
    ws["A8"] = "Executive Summary"
    ws["A8"].font = Font(bold=True)
    ws["A9"] = (
        f"Total GPU EC2 {COST_LABEL.lower()} changed from {fmt_usd(prior_total['total_net_amortized'])} "
        f"in {prior['word']} to {fmt_usd(current_total['total_net_amortized'])} in {current['word']} "
        f"({fmt_usd(delta_net)}, {fmt_pct(delta_pct)}). GPU instance hours changed by "
        f"{fmt_hours(delta_hours)} ({fmt_pct(hours_pct)})."
    )
    ws["A9"].alignment = Alignment(wrap_text=True)
    ws.merge_cells("A9:F9")
    row = write_table(
        ws,
        11,
        ["Metric", prior["label"], current["label"], "Change"],
        [
            [f"{COST_LABEL} (USD)", prior_total["total_net_amortized"], current_total["total_net_amortized"], delta_net],
            ["On-demand / unblended (USD)", prior_total["total_unblended"], current_total["total_unblended"], current_total["total_unblended"] - prior_total["total_unblended"]],
        ],
        usd_cols={2, 3, 4},
    )
    write_table(
        ws,
        row,
        ["Metric", prior["label"], current["label"], "Change"],
        [["GPU instance hours", int(round(prior_total["total_hours"])), int(round(current_total["total_hours"])), int(round(delta_hours))]],
    )
    autosize_columns(ws)

    ws2 = wb.create_sheet("By Instance Type")
    write_table(
        ws2,
        1,
        ["Instance", "GPU", f"{prior['short']} Hours", f"{current['short']} Hours", f"{prior['short']} {COST_LABEL}", f"{current['short']} {COST_LABEL}", "Delta USD", "Delta %"],
        comparison_rows(results, prior, current),
        usd_cols={5, 6, 7},
    )
    autosize_columns(ws2)

    if products:
        prior_products = {row["product"]: row for row in products[prior["label"]]["rows"]}
        current_products = {row["product"]: row for row in products[current["label"]]["rows"]}
        names = sorted(
            set(prior_products) | set(current_products),
            key=lambda name: -max(
                current_products.get(name, prior_products.get(name, {"net_amortized": 0}))["net_amortized"],
                prior_products.get(name, {"net_amortized": 0})["net_amortized"],
            ),
        )
        current_sum = sum(row["net_amortized"] for row in products[current["label"]]["rows"])
        product_rows = []
        for name in names:
            before = prior_products.get(name, {"net_amortized": 0})
            after = current_products.get(name, {"net_amortized": 0})
            if before["net_amortized"] < 1 and after["net_amortized"] < 1:
                continue
            delta = after["net_amortized"] - before["net_amortized"]
            pct = (delta / before["net_amortized"] * 100) if before["net_amortized"] else None
            share = (after["net_amortized"] / current_sum * 100) if current_sum else 0
            product_rows.append([name, before["net_amortized"], after["net_amortized"], share, delta, pct])
        ws3 = wb.create_sheet("By Product")
        write_table(
            ws3,
            1,
            ["Product", f"{prior['word']} {COST_LABEL}", f"{current['word']} {COST_LABEL}", f"{current['short']} share %", "Delta USD", "Delta %"],
            product_rows,
            usd_cols={2, 3, 5},
        )
        autosize_columns(ws3)
        cluster_title = f"Top EKS Clusters {current['word']}"
        if len(cluster_title) > 31:
            cluster_title = f"Top EKS Clusters {current['short']}"
        ws4 = wb.create_sheet(cluster_title)
        write_table(
            ws4,
            1,
            ["EKS cluster", "Hours", COST_LABEL],
            [[item["cluster"], item["hours"], item["net_amortized"]] for item in products[current["label"]]["clusters"]],
            usd_cols={3},
        )
        autosize_columns(ws4)

    regional_title = f"{current['word']} Regional"
    ws5 = wb.create_sheet(regional_title if len(regional_title) <= 31 else f"{current['short']} Regional")
    write_table(
        ws5,
        1,
        ["Instance type", "Region", "Hours", COST_LABEL, "On-demand"],
        [[row["instance_type"], row["region"], row["hours"], row["net_amortized"], row["unblended"]] for row in results[current["label"]]["by_region"]],
        usd_cols={4, 5},
    )
    autosize_columns(ws5)

    prior_region = {(row["instance_type"], row["region"]): row for row in results[prior["label"]]["by_region"]}
    current_region = {(row["instance_type"], row["region"]): row for row in results[current["label"]]["by_region"]}
    region_keys = sorted(set(prior_region) | set(current_region), key=lambda key: -(current_region.get(key) or prior_region[key])["net_amortized"])
    region_rows = []
    for key in region_keys:
        before = prior_region.get(key, {"net_amortized": 0})
        after = current_region.get(key, {"net_amortized": 0})
        if before["net_amortized"] < 1 and after["net_amortized"] < 1:
            continue
        region_rows.append([key[0], key[1], before["net_amortized"], after["net_amortized"], after["net_amortized"] - before["net_amortized"]])
    ws6 = wb.create_sheet("Regional Comparison")
    write_table(
        ws6,
        1,
        ["Instance", "Region", f"{prior['word']} {COST_LABEL}", f"{current['word']} {COST_LABEL}", "Change"],
        region_rows[:15],
        usd_cols={3, 4, 5},
    )
    autosize_columns(ws6)

    notes = wb.create_sheet("Methodology")
    for index, line in enumerate(
        [
            "Data source: AWS Cost Explorer in this account.",
            "Service filter: Amazon Elastic Compute Cloud - Compute.",
            "GPU instances identified by EC2 instance type and BoxUsage line items (p*, g*, inf*, trn* families).",
            f"Primary cost metric: {COST_LABEL} (Cost Explorer metric NetAmortizedCost).",
            "Net amortized cost excludes credits and refunds.",
            "On-demand / unblended cost shows list pricing where not covered by Savings Plans or RIs.",
            "Product breakdown uses the EC2 Product tag and aws:eks:cluster-name tag.",
        ],
        start=1,
    ):
        notes.cell(row=index, column=1, value=line)
    notes.column_dimensions["A"].width = 100

    payload = io.BytesIO()
    wb.save(payload)
    return payload.getvalue()


def highlights(results, prior, current):
    rows = comparison_rows(results, prior, current)
    decreases = sorted([row for row in rows if row[6] < -1], key=lambda row: row[6])[:3]
    newcomers = sorted([row for row in rows if row[4] < 1 and row[5] >= 1], key=lambda row: -row[5])[:3]
    decrease_text = ""
    if decreases:
        parts = [f"{row[0]} {fmt_usd(row[6])}" for row in decreases]
        if len(parts) == 1:
            decrease_text = parts[0]
        else:
            decrease_text = ", ".join(parts[:-1]) + ", and " + parts[-1]
    new_text = ""
    if newcomers:
        parts = [f"{row[0]} at {fmt_usd(row[5])}" for row in newcomers]
        if len(parts) == 1:
            new_text = parts[0]
        else:
            new_text = ", ".join(parts[:-1]) + ", and " + parts[-1]
    return decrease_text, new_text


def email_bodies(account, account_label, prior, current, results):
    prior_total = results[prior["label"]]
    current_total = results[current["label"]]
    delta_net = current_total["total_net_amortized"] - prior_total["total_net_amortized"]
    delta_pct = (delta_net / prior_total["total_net_amortized"] * 100) if prior_total["total_net_amortized"] else 0
    delta_hours = current_total["total_hours"] - prior_total["total_hours"]
    hours_pct = (delta_hours / prior_total["total_hours"] * 100) if prior_total["total_hours"] else 0
    decrease_text, new_text = highlights(results, prior, current)
    bullets = [
        f"Net amortized cost: {fmt_usd(prior_total['total_net_amortized'])} in {prior['word']} to {fmt_usd(current_total['total_net_amortized'])} in {current['word']} ({fmt_usd(delta_net)}, {fmt_pct(delta_pct)}).",
        f"GPU hours: {fmt_hours(prior_total['total_hours'])} to {fmt_hours(current_total['total_hours'])} ({fmt_hours(delta_hours)}, {fmt_pct(hours_pct)}).",
    ]
    if decrease_text:
        bullets.append(f"Largest decreases: {decrease_text}.")
    if new_text:
        bullets.append(f"New in {current['word']}: {new_text}.")
    plain_lines = [
        "Hi Team,",
        "",
        f"Attached is the {prior['label']} versus {current['label']} GPU cost report for {account_label}.",
        "",
        f"{account_label} (account {account})",
        "",
    ]
    plain_lines.extend(f"- {bullet}" for bullet in bullets)
    plain_lines.extend(["", "Thanks", "Jeeva"])
    html_items = "".join(f"<li>{bullet}</li>" for bullet in bullets)
    html = (
        "<html><body style=\"font-family: Calibri, Arial, sans-serif; font-size: 14px; color: #222;\">"
        "<p>Hi Team,</p>"
        f"<p>Attached is the {prior['label']} versus {current['label']} GPU cost report for {account_label}.</p>"
        f"<p><b>{account_label}</b> (account {account})</p><ul>{html_items}</ul>"
        "<p>Thanks<br>Jeeva</p></body></html>"
    )
    return "\n".join(plain_lines), html


def parameter_value(ssm, name):
    return ssm.get_parameter(Name=name)["Parameter"]["Value"]


def lambda_handler(event, context):
    now = datetime.now(IST)
    prior, current = two_complete_months(now)
    account = boto3.client("sts").get_caller_identity()["Account"]
    account_label = os.environ.get("ACCOUNT_LABEL", "Aidev")
    ce = boto3.client("ce", region_name="us-east-1")
    results = load_usage(ce, prior, current)
    products = load_tags(ce, prior, current)
    generated_at = now.strftime("%Y-%m-%d %H:%M")
    workbook = build_workbook(account, account_label, prior, current, results, products, generated_at)
    filename = f"{account_label}-GPU-Cost-Report-{prior['short']}-{current['short']}-{prior['start'][:4]}.xlsx".replace(" ", "-")
    key = f"reports/{prior['start']}-vs-{current['start']}/{now.strftime('%Y%m%dT%H%M%S')}-{filename}"
    boto3.client("s3").put_object(
        Bucket=os.environ["REPORT_BUCKET"],
        Key=key,
        Body=workbook,
        ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        ServerSideEncryption="AES256",
    )
    ssm = boto3.client("ssm")
    from_address = parameter_value(ssm, os.environ["FROM_PARAMETER"])
    to_addresses = [item.strip() for item in parameter_value(ssm, os.environ["TO_PARAMETER"]).split(",") if item.strip()]
    plain, html = email_bodies(account, account_label, prior, current, results)
    subject = f"{account_label} GPU cost report: {prior['label']} vs {current['label']}"
    message = MIMEMultipart("mixed")
    message["Subject"] = subject
    message["From"] = from_address
    message["To"] = ", ".join(to_addresses)
    alternative = MIMEMultipart("alternative")
    alternative.attach(MIMEText(plain, "plain", "utf-8"))
    alternative.attach(MIMEText(html, "html", "utf-8"))
    message.attach(alternative)
    attachment = MIMEApplication(workbook, _subtype="vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    attachment.add_header("Content-Disposition", "attachment", filename=filename)
    message.attach(attachment)
    sent = boto3.client("ses").send_raw_email(
        Source=from_address,
        Destinations=to_addresses,
        RawMessage={"Data": message.as_string()},
    )
    prior_total = results[prior["label"]]
    current_total = results[current["label"]]
    return {
        "account": account,
        "period": f"{prior['label']} vs {current['label']}",
        "prior_net_amortized": round_usd(prior_total["total_net_amortized"]),
        "current_net_amortized": round_usd(current_total["total_net_amortized"]),
        "s3_key": key,
        "ses_message_id": sent["MessageId"],
        "to": to_addresses,
    }
