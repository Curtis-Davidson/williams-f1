# Purpose: Unified CLI tool using click
import click
import glob
from tools.generate_report import generate_report

@click.group()
def cli():
    pass

@cli.command()
@click.option("--input", required=True, help="Path to user JSON")
def generate(input):
    json_out, md_out = generate_report(input)
    click.echo(f" Markdown: {md_out}")
    click.echo(f" JSON: {json_out}")

@cli.command()
@click.option("--input-folder", default="/mnt/data/ADUserDiscoveryTool/input", help="Folder of user_*.json")
def batch(input_folder):
    files = glob.glob(f"{input_folder}/user_*.json")
    click.echo(f"🔍 Found {len(files)} JSONs...")
    for file in files:
        click.echo(f"️  Processing {file}")
        json_out, md_out = generate_report(file)
        click.echo(f" Markdown: {md_out}")
        click.echo(f" JSON: {json_out}")

if __name__ == "__main__":
    cli()