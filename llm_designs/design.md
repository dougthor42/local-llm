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
A key feature is the ability to spin up the agent and harness from *any
particular directory*. The **mounted workspace** within the container will be
**driven by the Current Working Directory (CWD)** from which the execution
script is run.
*   **Project Scope:** For each project, a dedicated `.agent_data/` directory will
    be created within the CWD. The container will have **read-write access**
    to this specific `.agent_data/` directory and to the CWD. This enforces a
    strict boundary where the agent can only read/write to the files within its
    project scope.

### C. Model Management
*   **Model Paths:** Model files are stored in a central host location. The harness
    containers access these models dynamically, selecting the desired model
    without the container image needing to know the specific model file
    paths.

### D. State Persistence (Hybrid Model)
We use a hybrid persistence strategy to separate project data from global state:
*   **Project State (Ephemeral/Project-Bound):** Data specific to a project, such as
    scratch files and immediate outputs, will be stored within the container's
    mounted project workspace (`.agent_data/`).
*   **Global Agent State (Persistent/Global Cache):** All global agent state
    (logs, chat histories, conversation IDs, cached outputs, etc.) will be
    stored in a dedicated, persistent location on the host (e.g.,
    `~/.llm_agent_cache`), ensuring state survives container restarts.

## 3. Design Decisions & Constraints

*   **Isolation Mechanism:** Container volume mounts are the mechanism for
    data isolation.
*   **Host Interaction:** No host interaction is planned for the MVP.
*   **Dependencies:** We rely on external management for system dependencies
    and focus the container on the LLM runtime (e.g., `llama.cpp`).
*   **Entry Point:** The MVP uses `run.sh` as the primary entry point.
    *   **Orchestration:** `podman-compose` ensures the model container (e.g.,
        `llama-server`) is started and ready before the agent/harness container
        is brought up.
*   **Model Switching:** The harness is designed to handle model selection
    dynamically based on host model locations, rather than requiring complex
    logic within the container image.
*   **Versioning/Debugging:** Versioning and standardized debugging are deferred
    to future work.
