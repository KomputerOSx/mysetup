# Setup Wizard Steps

Each selectable block lives in its own `*.sh` file in this directory.

To add another block:

1. Create a numbered file, for example `11_docker.sh`.
2. Define a function that performs the setup work.
3. Register it at the bottom of the file:

```bash
run_docker() {
    step_start "Installing Docker"

    # setup commands here

    step_done "Docker installed"
}

register_step "docker" "Docker installation" "run_docker"
```

Files are sourced in filename order, so the numeric prefix controls menu order and execution order.

Run `./script.sh --dry-run` to choose steps and preview the run without making changes.
