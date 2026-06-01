#!/bin/bash
set -e

echo "==================================="
echo " Running ada-snippets checks..."
echo "==================================="

cd ada

echo "1. Building..."
alr build

echo "2. Running AUnit Tests..."
./bin/test_runner

echo "3. Running SPARK Prover..."
alr gnatprove

echo "4. Generating JSON..."
./bin/gen_snippets > ../snippets/ada.json

# Check if JSON generation caused uncommitted changes to snippets/ada.json
if ! git diff --exit-code ../snippets/ada.json > /dev/null; then
  echo "Error: snippets/ada.json is out of date. The pre-commit hook regenerated it."
  echo "Please 'git add snippets/ada.json' and commit again."
  exit 1
fi

echo "==================================="
echo " All checks passed!"
echo "==================================="
exit 0
