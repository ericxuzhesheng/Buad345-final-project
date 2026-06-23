#!/usr/bin/env python3
"""Generate a packaged Tableau workbook (.twbx) for the Cainiao story.

Builds three worksheets (Punchline, Hours-saved, Segments) plus a dashboard,
each backed by a pre-aggregated CSV from tableau_data/, and zips everything
(workbook + data) into tableau/Cainiao_Story.twbx so it opens with a double-click.

Run:  python scripts/build_twbx.py
"""
import os
import csv
import zipfile
import xml.etree.ElementTree as ET

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(ROOT, "tableau_data")
OUT_TWBX = os.path.join(ROOT, "tableau", "Cainiao_Story.twbx")
VERSION = "18.1"

# Numeric columns -> measures; everything else -> string dimension.
NUMERIC = {"n_orders", "avg_totaltime", "avg_review",
           "Cainiao", "Non.Cainiao", "cainiao_hours_saved", "avg_hours"}


def col_type(name):
    return ("real", "measure", "quantitative") if name in NUMERIC \
        else ("string", "dimension", "nominal")


def read_header(csv_name):
    with open(os.path.join(DATA_DIR, csv_name), newline="", encoding="utf-8") as f:
        return next(csv.reader(f))


def datasource_xml(ds_name, csv_name, cols):
    """One federated text-file datasource."""
    conn = f"textscan.{ds_name}"
    rel_cols = "".join(
        f"<column datatype='{col_type(c)[0]}' name='{c}' ordinal='{i}'/>"
        for i, c in enumerate(cols))
    meta = ""
    for i, c in enumerate(cols):
        dt = col_type(c)[0]
        agg = "Sum" if dt == "real" else "Count"
        meta += (
            "<metadata-record class='column'>"
            f"<remote-name>{c}</remote-name>"
            f"<local-name>[{c}]</local-name>"
            f"<parent-name>[{csv_name}]</parent-name>"
            f"<remote-alias>{c}</remote-alias>"
            f"<ordinal>{i}</ordinal>"
            f"<local-type>{dt}</local-type>"
            f"<aggregation>{agg}</aggregation>"
            "</metadata-record>")
    col_defs = ""
    for c in cols:
        dt, role, typ = col_type(c)
        col_defs += (f"<column datatype='{dt}' name='[{c}]' "
                     f"role='{role}' type='{typ}'/>")
    return f"""
  <datasource caption='{ds_name}' inline='true' name='{ds_name}' version='{VERSION}'>
    <connection class='federated'>
      <named-connections>
        <named-connection caption='{csv_name}' name='{conn}'>
          <connection class='textscan' directory='Data/csv' filename='{csv_name}'
            password='' server='' validate='no'/>
        </named-connection>
      </named-connections>
      <relation connection='{conn}' name='{csv_name}'
        table='[{csv_name}]' type='table'>
        <columns header='yes' outcome='6'>{rel_cols}</columns>
      </relation>
      <metadata-records>{meta}</metadata-records>
    </connection>{col_defs}
  </datasource>"""


def instance(col):
    """Return (instance-name, derivation) for a shelf placement."""
    dt = col_type(col)[0]
    if dt == "real":
        return f"[sum:{col}:qk]", "Sum"
    return f"[none:{col}:nk]", "None"


def deps_xml(ds_name, cols, used):
    """datasource-dependencies block for a worksheet."""
    out = [f"<datasource-dependencies datasource='{ds_name}'>"]
    for c in cols:
        dt, role, typ = col_type(c)
        out.append(f"<column datatype='{dt}' name='[{c}]' role='{role}' type='{typ}'/>")
    for c in used:
        nm, deriv = instance(c)
        dt, role, typ = col_type(c)
        out.append(
            f"<column-instance column='[{c}]' derivation='{deriv}' "
            f"name='{nm}' pivot='key' type='{typ}'/>")
    out.append("</datasource-dependencies>")
    return "".join(out)


def worksheet_xml(name, ds_name, cols, row_cols, col_cols, color=None):
    used = list(dict.fromkeys(row_cols + col_cols + ([color] if color else [])))
    rows_expr = " / ".join(f"[{ds_name}].{instance(c)[0]}" for c in row_cols)
    cols_expr = " / ".join(f"[{ds_name}].{instance(c)[0]}" for c in col_cols)
    enc = ""
    if color:
        enc = f"<encodings><color column='[{ds_name}].{instance(color)[0]}'/></encodings>"
    return f"""
  <worksheet name='{name}'>
    <table>
      <view>
        <datasources>
          <datasource caption='{ds_name}' name='{ds_name}'/>
        </datasources>
        {deps_xml(ds_name, cols, used)}
        <aggregation value='true'/>
      </view>
      <style/>
      <panes>
        <pane selection-relaxation-option='selection-relaxation-allow'>
          <view><breakdown value='auto'/></view>
          <mark class='Bar'/>
          {enc}
        </pane>
      </panes>
      <rows>({rows_expr})</rows>
      <cols>({cols_expr})</cols>
    </table>
  </worksheet>"""


def dashboard_xml(name, sheets):
    zones = ""
    for i, s in enumerate(sheets):
        zones += (f"<zone h='{100000//len(sheets)}' name='{s}' w='98000' "
                  f"x='1000' y='{1000 + i*(98000//len(sheets))}'/>")
    return f"""
  <dashboards>
    <dashboard name='{name}'>
      <style/>
      <size maxheight='2000' maxwidth='1600' minheight='2000' minwidth='1600'/>
      <zones>
        <zone h='100000' w='100000' x='0' y='0'>{zones}</zone>
      </zones>
    </dashboard>
  </dashboards>"""


def main():
    specs = [
        ("cainiao_cells", "agg_cainiao_lcsize_citysize.csv"),
        ("cainiao_gain",  "agg_cainiao_gain_by_cell.csv"),
        ("cainiao_seg",   "agg_time_segments.csv"),
    ]
    headers = {ds: read_header(csv) for ds, csv in specs}

    datasources = "".join(
        datasource_xml(ds, csv, headers[ds]) for ds, csv in specs)

    sheets = [
        worksheet_xml("1. Cainiao is faster (2x2)", "cainiao_cells",
                      headers["cainiao_cells"],
                      row_cols=["avg_totaltime"],
                      col_cols=["Citysize", "LCsize"], color="cainiao"),
        worksheet_xml("2. Hours saved (reversal)", "cainiao_gain",
                      headers["cainiao_gain"],
                      row_cols=["cainiao_hours_saved"],
                      col_cols=["Citysize", "LCsize"]),
        worksheet_xml("3. Time segments", "cainiao_seg",
                      headers["cainiao_seg"],
                      row_cols=["avg_hours"],
                      col_cols=["Citysize", "LCsize", "segment"], color="cainiao"),
    ]
    sheet_names = ["1. Cainiao is faster (2x2)", "2. Hours saved (reversal)",
                   "3. Time segments"]

    twb = (f"<?xml version='1.0' encoding='utf-8' ?>\n"
           f"<workbook version='{VERSION}'>\n"
           f"  <datasources>{datasources}\n  </datasources>\n"
           f"  <worksheets>{''.join(sheets)}\n  </worksheets>\n"
           f"{dashboard_xml('Cainiao Story', sheet_names)}\n"
           f"</workbook>\n")

    # Well-formedness check before packaging.
    ET.fromstring(twb)

    twb_path = os.path.join(ROOT, "tableau", "Cainiao_Story.twb")
    with open(twb_path, "w", encoding="utf-8") as f:
        f.write(twb)

    with zipfile.ZipFile(OUT_TWBX, "w", zipfile.ZIP_DEFLATED) as z:
        z.write(twb_path, "Cainiao_Story.twb")
        for _, csv_name in specs:
            z.write(os.path.join(DATA_DIR, csv_name), f"Data/csv/{csv_name}")
    os.remove(twb_path)
    print("OK ->", OUT_TWBX)
    print("XML well-formed; packaged", len(specs), "CSVs.")


if __name__ == "__main__":
    main()
