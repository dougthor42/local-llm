# Project Design: Standalone LLM Agent Container System

## 1. Purpose
The primary goal of this project is to create a **standalone, portable LLM
agent container system** that enables users to use a local-model LLM within any
particular project.

It also enables testing out a variety of local-only language models and
privacy-friendly agent harnesses without installing any dependencies on the
host machine.

## 2. Core Architecture

### A. Containerization (Podman)
The entire system is encapsulated within one or more Docker containers managed
by **Podman**. This ensures:
*   **Isolation:** Each agent and harness is isolated from the host, except for
    the workspace the container is working in.
*   **Portability:** The entire setup (model, runtime, dependencies) is
    self-contained, modulo any required host config in order to support things
    like GPU container passthrough.
*   **Privacy:** Running everything in containers adheres to a privacy-friendly
    approach.

### B. Dynamic Directory Scoping
A key feature is the ability to spin up a the agent and harness from *any
particular directory*. The **mounted workspace** within the container will be
**driven by the Current Working Directory (CWD)** from which the execution
script is run. This allows the agent to make edits to a given project without
being able to edit other projects.

For example, if the container system is called from the `/foo/bar/baz`
directory, it can read, edit, and create files within `/foo/bar/baz/**`, but
not files in `/foo/bar/foobar` or `/foo/other`.

The agent and harness inside the container will have **read-write access** to the
workspace directory. Any agent state, logs, and intermediate results will have
to be written to that specific workspace. Future work may extend this so that
agent state, logs, and results are stored in a more central location (such as
`~/.cache`) in order to keep project directories clean, but for the initial
version we store in the workspace.

## 3. Design Decisions & Constraints (Based on Discussion)

*   **Model Paths:** Models (gguf files) paths are stored in a central host
    location. This allows each harness to access all models and select one as
    desired, such as through a `/model` command.
*   **Isolation Mechanism:** Container volume mounts are the mechanism for
    data isolation.
*   **Host Interaction:** No host interaction is planned for the MVP.
*   **Dependencies:** We rely on external management for system dependencies
    (e.g., nvidia-container-toolkit) and focus the container on the LLM runtime
    (e.g., llama.cpp).
*   **State Persistence:** For the MVP, state will be ephemeral (container
    restart means start over). Persistence is a planned future feature.
*   **Entry Point:** The MVP uses `run.sh` as the primary entry point, with
    a future `run_agent` script on `$PATH`.

## 4. Key Components

*   **Model Containers:** Spin up environments tailored for specific LLM
    architectures.
*   **Harness Containers:** Lightweight containers providing the agent's
    runtime environment.

## 5. Execution Flow (Conceptual)

1.  **Run:** `run.sh` uses `podman-compose` to start the model service container
    and the agent/harness container, ensuring the harness is mounted with
    read-only access to the current CWD.
    +   The services define a `build` mapping that defines the `context` and
        `dockerfile`, and podman-compose builds the container when needed.

## 6. Benefits
*   **Portability:** Highly portable, requiring only Podman/Compose on the host.
*   **Experimentation Speed:** Rapid prototyping through CWD-driven model loading.
*   **Security & Privacy:** Strong container isolation.
