import matplotlib.pyplot as plt
import pandas as pd
def plot_virtue_vice(df: pd.DataFrame, target: str, outputpath: str):
    ax = df.plot.line(y=[f'{target}_virtue', f'{target}_vice'])
    fig = ax.get_figure()
    fig.savefig(outputpath + target + '_both.jpg')

def plot_domains(df: pd.DataFrame, target: str, domains: list, outputpath: str):
    ax = df.plot.line(y=[f'{target}_{domain}' for domain in domains])
    fig = ax.get_figure()
    fig.savefig(outputpath + target + '_domains.jpg')

def plot_diff(df: pd.DataFrame, target: str, eventyear: int, eventname: str, outputpath: str):
    ax = df.plot.line(y=[f'{target}_diff'], title=f'{target}_diff')
    lineyear = eventyear - 1950
    ax.axvline(lineyear, color="blue", linestyle="--")
    ymax = df[f'{target}_diff'].max()
    ax.text(lineyear + 1, ymax, eventname, color='blue')
    fig = ax.get_figure()
    fig.savefig(outputpath + target + '_diff.jpg')

def plot_sum(df: pd.DataFrame, target: str, outputpath: str):
    ax = df.plot.line(y=[f'{target}_sum'])
    fig = ax.get_figure()
    fig.savefig(outputpath + target + '_sum.jpg')

def plot_results(df: pd.DataFrame, targets: dict, eventyear: int, eventname: str, outputpath: str, foundations: list):
    domains = list(set([foundation.split('_')[0] for foundation in foundations]))
    for target in targets:
        plot_virtue_vice(df, target, outputpath)
        plot_domains(df, target, domains, outputpath)
        plot_diff(df, target, eventyear, eventname, outputpath)
        plot_sum(df, target, outputpath)
