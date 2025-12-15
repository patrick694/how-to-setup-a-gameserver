#!/bin/bash
echo "🎬 Recording demo in 3 seconds..."
sleep 3

asciinema rec docs/demo.cast --overwrite --command "bash docs/record-demo.sh"

echo ""
echo "✅ Recording saved to docs/demo.cast"
echo ""
echo "Upload to asciinema.org:"
echo "  asciinema upload docs/demo.cast"
echo ""
echo "Or embed in README:"
echo "  [![asciicast](https://asciinema.org/a/YOUR_ID.svg)](https://asciinema.org/a/YOUR_ID)"
