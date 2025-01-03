"""Compute several alternate correlates of complexity for the oil extraction and artistic performance industries."""

import pandas as pd
import numpy as np
from IPython.display import display

# Data source:
# https://www.bls.gov/oes/tables.htm
# OEWS (Occupational Employment and Wage Estimates) data
# National xls table, 2023

# Data source note on PCT_TOTAL:
# "Percent of industry employment in the given occupation. Percents may not sum to 100 because the totals may include data for occupations that could not be published separately. Only available for the national industry estimates; otherwise, this column is blank. "


def load_data():
    return (
        pd.read_excel(
            "../data/nat4d_M2023_dl.xlsx",
            usecols=[
                "NAICS",
                "NAICS_TITLE",
                "OCC_CODE",
                "OCC_TITLE",
                "O_GROUP",
                "PCT_TOTAL",
                "A_MEDIAN",
            ],
        )
        .rename(lambda s: s.lower(), axis=1)
        .replace("**", np.nan)
        .replace("*", np.nan)
        .replace("#", 239200)
        # "#  = indicates a wage equal to or greater than $115.00 per hour or $239,200 per year"
        # .astype({"pct_total": float, "a_median": float})
        .query('o_group == "minor"')
    )


# Load & preporocess data
industry_occ_data = load_data()

# Augment with RCA and other vars
industry_occ_data = industry_occ_data.assign(
    avg_pct=lambda df: df.groupby("occ_code")["pct_total"].transform("mean"),
    rca=lambda df: df["pct_total"] / df.avg_pct,
    pct_01=lambda df: df["pct_total"] > 1.0,
    pct_03=lambda df: df["pct_total"] > 3.0,
    pct_05=lambda df: df["pct_total"] > 5.0,
)

# Compute diversity vars for each industry
industry_data = pd.DataFrame()
industry_data["name"] = industry_occ_data.groupby("naics")["naics_title"].first()
industry_data["num_rca_gt1"] = industry_occ_data.groupby("naics")["rca"].apply(
    lambda rcas: (rcas > 1).sum()
)
industry_data["num_share_gt1"] = industry_occ_data.groupby("naics")["pct_01"].sum()
industry_data["exp_entropy"] = industry_occ_data.groupby("naics")["pct_total"].apply(
    lambda pcts: np.exp(-np.sum(pcts / 100 * np.log(pcts / 100)))
)
industry_data["mean_wage"] = industry_occ_data.groupby("naics")["a_median"].median()

# Rank industries by these variables
industry_rank_data = pd.DataFrame()
industry_rank_data["name"] = industry_data["name"]
industry_rank_data["num_rca_gt1"] = industry_data["num_rca_gt1"].rank(ascending=False)
industry_rank_data["num_share_gt1"] = industry_data["num_share_gt1"].rank(
    ascending=False
)
industry_rank_data["exp_entropy"] = industry_data["exp_entropy"].rank(ascending=False)
industry_rank_data["mean_wage"] = industry_data["mean_wage"].rank(ascending=False)

# Show results for oil extraction and artistic performance
selected_industries = [
    "211100",  # Oil and gas extraction
    "711500",  # Independent artists, writers, and performers
]
print("\nIndustry values")
display(industry_data.query("naics in @selected_industries"))
print("Industry ranks")
display(industry_rank_data.query("naics in @selected_industries"))
print(f"Number of industries in data: {len(industry_rank_data)}")
