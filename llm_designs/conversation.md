# Conversation Log: Design & Architecture Decisions

## Initial Context
The project aims to build a standalone, privacy-friendly LLM agent system using
Podman to run local models without host dependencies, while strictly isolating
model directories.

## Key Discussion Points & Decisions

**1. Model Source of Truth & Dynamic Loading**
*   **Initial Idea:** Models live in a single shared directory.
*   **Decision:** The model path will be driven by the Current Working
    Directory (CWD) from which the "start agent" script/command is executed.
    This provides dynamic and simple model switching.

**2. Security and Scoping**
*   **Mechanism:** Strict scoping will be enforced using **container volume
    mounts**. This will ensure the agent container has read-only access only to
    the specific model directory.
*   **Host Interaction:** No host interaction is planned for the MVP, keeping
    the design clean and focused.

**3. Runtime and Dependencies**
*   **Tooling:** `podman` and `podman-compose` are the core orchestration
    tools.
*   **Dependencies:** External dependencies like `nvidia-container-toolkit`
    will be managed externally by the user/environment setup, keeping the
    container image focused on the LLM runtime.

**4. State Persistence**
*   **Initial State:** Ephemeral (container restarts mean start over).
*   **Future Goal:** Persistence is a planned future feature to be addressed
    after the MVP.

**5. User Interface & Entry Point**
*   **MVP Entry Point:** The MVP is validated by the `run.sh` script.
*   **Future Entry Point:** A dedicated `run_agent` script on `$PATH` is
    sufficient for the MVP but is open for alternative, more complex CLI/UI
    designs later.

## Summary of Design Philosophy
The final design is a minimal, container-native system where the *context* (the
CWD) dictates the *data* (the model path), and *isolation* (volume mounts)
dictates the *security*. We prioritize portability and zero host software
installation.
