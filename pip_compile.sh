#!/bin/bash
uv pip compile --generate-hashes --no-strip-extras --output-file=requirements.txt --emit-index-url requirements.in
