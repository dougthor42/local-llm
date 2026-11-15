# Conversation Log: Design & Architecture Decisions

## Initial Context
The project aims to build a standalone, privacy-friendly LLM agent system using
Podman to run local models without host dependencies, while strictly isolating
model directories.

## Key Discussion Points & Decisions

**1. Model Source of Truth & Dynamic Loading**
*   **Decision:** The model paths (gguf files) will be stored in a central host
    location. This allows the harness to access all models and select one as
    desired, abstracting the underlying model complexity from the container.

**2. Security and Scoping**
*   **Mechanism:** Strict scoping will be enforced using **container volume
    mounts**. The primary operational workspace for any project will be
    mounted as read-write access to a directory within the project root,
    specifically `.agent_data/`.

**3. Runtime and Dependencies**
*   **Tooling:** `podman` and `podman-compose` are the core orchestration
    tools.
*   **Dependencies:** External dependencies (e.g., `nvidia-container-toolkit`)
    will be managed externally by the user/environment setup, keeping the
    container image focused on the LLM runtime.

**4. State Persistence (Hybrid Model)**
*   **Strategy:** We are adopting a hybrid persistence model.
    *   **Project State:** Data specific to a project (scratch files, immediate
        outputs) will be stored within the container's workspace directory
        (`/.agent_data/`). This data is ephemeral and tied to the project.
    *   **Global Agent State:** Global agent state (chat histories, logs,
        conversation IDs, cached outputs) will be stored in a persistent,
        external host location (e.g., `~/.llm_agent_cache`), ensuring state
        survives container restarts.

**5. User Interface & Entry Point**
*   **MVP Entry Point:** The MVP is validated by the `run.sh` script.
*   **Future Entry Point:** A dedicated `run_agent` script on `$PATH` is
    open for later complexity, but the MVP relies solely on `run.sh`.

## Summary of Design Philosophy
The final design is a container-native system where the CWD dictates the
project context (via `.agent_data/`), and container isolation ensures security
while a dedicated external directory manages global agent state persistence.
