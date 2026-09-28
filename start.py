#!/usr/bin/env python3
"""
OS Lab Linux Environment Launcher
Starts the minimal Ubuntu Docker container and opens an interactive Linux bash terminal.
Mounted workspace: ./src -> /workspace
"""

import os
import sys
import shutil
import subprocess
from pathlib import Path

# ANSI colors for friendly terminal output
GREEN = "\033[92m"
BLUE = "\033[94m"
YELLOW = "\033[93m"
RED = "\033[91m"
BOLD = "\033[1m"
RESET = "\033[0m"


def check_prerequisites():
    """Verify that Docker is installed and the Docker daemon is running."""
    if not shutil.which("docker"):
        print(f"{RED}[Error]{RESET} 'docker' command not found. Please install Docker Desktop.")
        sys.exit(1)

    # Check if Docker daemon is running
    res = subprocess.run(
        ["docker", "info"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    if res.returncode != 0:
        print(f"{RED}[Error]{RESET} Docker daemon is not running.")
        print(f"{YELLOW}[Tip]{RESET} Please start Docker Desktop and try again.")
        sys.exit(1)


def main():
    script_dir = Path(__file__).resolve().parent
    os.chdir(script_dir)

    # Simple CLI argument handling for stop / down / rebuild
    if len(sys.argv) > 1:
        cmd = sys.argv[1].lower()
        if cmd in ("--stop", "stop"):
            print(f"{BLUE}Stopping OS Lab container...{RESET}")
            subprocess.run(["docker", "compose", "stop"])
            return
        elif cmd in ("--down", "down"):
            print(f"{YELLOW}Stopping and removing OS Lab container...{RESET}")
            subprocess.run(["docker", "compose", "down"])
            return
        elif cmd in ("--rebuild", "rebuild"):
            print(f"{BLUE}Rebuilding OS Lab container image...{RESET}")
            subprocess.run(["docker", "compose", "build"])
            return
        elif cmd in ("-h", "--help", "help"):
            print(f"Usage:")
            print(f"  python3 start.py            Start and attach to interactive Linux terminal")
            print(f"  python3 start.py --stop     Pause/stop the running container")
            print(f"  python3 start.py --down     Stop and remove the container")
            print(f"  python3 start.py --rebuild  Rebuild Docker image")
            return

    print(f"\n{BOLD}{BLUE}================================================={RESET}")
    print(f"{BOLD}{GREEN}      Starting Ubuntu OS Lab Environment         {RESET}")
    print(f"{BOLD}{BLUE}================================================={RESET}")
    print(f"Directory: {script_dir}")
    print(f"Mounted:   {script_dir / 'src'} -> /workspace (inside container)")
    print(f"Base OS:   Ubuntu 24.04 LTS (Minimal)\n")

    check_prerequisites()

    # Ensure src directory exists
    (script_dir / "src").mkdir(exist_ok=True)

    # Start container in background (builds if not yet built)
    print(f"{BLUE}[1/2]{RESET} Ensuring container is running...")
    up_cmd = ["docker", "compose", "up", "-d"]
    ret = subprocess.run(up_cmd)
    if ret.returncode != 0:
        print(f"{RED}[Error]{RESET} Failed to start docker container.")
        sys.exit(ret.returncode)

    # Attach interactive terminal
    print(f"{GREEN}[2/2]{RESET} Entering Linux terminal...\n")
    print(f"{YELLOW}Hint: Type 'exit' to leave the container.{RESET}\n")

    try:
        # docker compose exec with interactive TTY
        subprocess.run(["docker", "compose", "exec", "os-lab", "bash"])
    except KeyboardInterrupt:
        pass

    print(f"\n{BOLD}{BLUE}================================================={RESET}")
    print(f"{GREEN}You have exited the Linux container.{RESET}")
    print(f"Container 'os-lab-env' is running in the background.")
    print(f" - Run '{BOLD}python3 start.py{RESET}' to re-enter anytime.")
    print(f" - Run '{BOLD}python3 start.py --stop{RESET}' (or 'docker compose stop') to stop it.")
    print(f" - Run '{BOLD}python3 start.py --down{RESET}' (or 'docker compose down') to remove.")
    print(f"{BOLD}{BLUE}================================================={RESET}\n")


if __name__ == "__main__":
    main()
