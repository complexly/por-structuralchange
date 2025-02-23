# %%
import pandas as pd
from IPython.display import display
from constants import SAVE_FOLDER, DATA_FOLDER, OUT_FOLDER


# %%
# Load data
countries = pd.read_csv(f"{SAVE_FOLDER}/region_year_metric.tsv", sep="\t")

# %%
# Map country names to codes
codes_and_names = pd.read_csv(f"{DATA_FOLDER}/Code2Country.csv")

# Merge
countries = countries.merge(
    codes_and_names, left_on="region", right_on="region_code", how="left"
).drop("region_code", axis=1)

# %%
# Average across recent n years


# Extract last n years
n_years = 10
recent_years = list(range(2018 - n_years + 1, 2018 + 1))
(
    countries.query("year in @recent_years")
    .groupby(["region", "region_name"])
    .agg("mean")
    .reset_index()
    .sort_values("proj_p", ascending=False)[["region", "region_name", "proj_p"]]
)


# %%
# Pick most recent year
year = 2018

# Filter and sort
countries_ranked = (
    countries.query("year==@year")
    .query("population > 1e5")
    .sort_values("proj_p", ascending=False)
    # .set_index(["year", "region"])
    .dropna(axis=0)
    .round({"proj_p": 4, "eci": 4})
    .assign(rank=lambda df: df.proj_p.rank(ascending=False).astype(int))
    .assign(eci_rank=lambda df: df.eci.rank(ascending=False).astype(int))[
        ["rank", "region", "region_name", "proj_p", "eci", "eci_rank"]
    ]
)

# Display
print(f"Countries ranked by ECIstar in {year}")
display(countries_ranked)

# # To latex
countries_ranked.to_latex(
    f"{OUT_FOLDER}/ECIstar_ranking.tex",
    index=False,
    formatters={"proj_p": "{:.4f}", "eci": "{:.4f}"},
)
