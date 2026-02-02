# oi - One-Command LLM Chat Interface

`oi` is a simple bash script that makes running local LLMs with llama.cpp as easy as typing a single command. It handles model selection, downloading, and launching interactive chat sessions.

## Features

- **One-command operation**: Just type `oi` and start chatting
- **Smart model recommendations**: Automatically filters models based on your hardware
- **Curated model catalog**: Pre-configured with high-quality models from HuggingFace
- **Automatic downloads**: Downloads models on-demand using curl
- **Hardware detection**: Detects GPU VRAM and CPU specs for optimal model matching
- **Simple CLI interface**: Support for direct model selection and custom downloads

## Requirements

- Linux system with bash
- [llama.cpp](https://github.com/ggml-org/llama.cpp) built from source
- curl (for downloading models)
- Optional: NVIDIA GPU with CUDA for faster inference

## Installation

### 1. Install llama.cpp

First, you need to clone and build llama.cpp:

```bash
# Clone the repository
git clone https://github.com/ggml-org/llama.cpp.git ~/llama.cpp

# Build with CUDA support (if you have an NVIDIA GPU)
cd ~/llama.cpp
cmake -B build -DGGML_CUDA=ON
cmake --build build --config Release

# Or build for CPU only
cmake -B build
cmake --build build --config Release
```

### 2. Install oi

Clone or copy the `local_script` directory to your home folder:

```bash
# If cloning from a repository
git clone <repository-url> ~/local_script

# Make the script executable
chmod +x ~/local_script/oi
```

### 3. Add to PATH (Optional)

To use `oi` from anywhere, add it to your PATH:

```bash
# Add to your ~/.bashrc or ~/.zshrc
echo 'export PATH="$HOME/local_script:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Quick Start

### Interactive Mode

Simply run `oi` to enter the interactive menu:

```bash
oi
```

This will:
1. Detect your hardware (VRAM, RAM, CPU)
2. Show a menu of compatible models
3. Download the model if not present
4. Launch an interactive chat session

### Direct Model Selection

Start chatting with a specific model immediately:

```bash
oi -m qwen2.5-3b
```

### List Available Models

See all models and their compatibility with your system:

```bash
oi -l
```

### Check Hardware

Display your system specifications:

```bash
oi -h
```

## Usage

```
oi [OPTIONS]

OPTIONS:
    -m, --model <id>         Directly select model by ID
    -q, --quant <quant>      Specify quantization (default: Q4_K_M)
    -l, --list              List available models
    -i, --installed         List installed models only
    -d, --download <path>   Download custom model from HuggingFace
    -h, --hardware          Show system hardware information
    -c, --context <size>    Set context size (default: 4096)
    -t, --threads <num>     Set number of CPU threads
    --help                  Show help message
```

## Examples

### Start interactive chat
```bash
oi
```

### Chat with specific model
```bash
oi -m qwen2.5-3b
```

### Use different quantization
```bash
oi -m mistral-7b -q Q5_K_M
```

### Download a custom model
```bash
oi -d microsoft/Phi-3-mini-4k-instruct-gguf/Phi-3-mini-4k-instruct.Q4_K_M.gguf
```

### List all available models
```bash
oi -l
```

### Show installed models
```bash
oi -i
```

### Check system specs
```bash
oi --hardware
```

### Adjust context size and threads
```bash
oi -m qwen2.5-7b -c 8192 -t 8
```

## Available Models

The following models are pre-configured in the catalog:

### Small Models (2-4GB VRAM)
- **qwen2.5-3b**: Fast multilingual model, excellent for coding
- **phi-3-mini**: Microsoft's efficient small model
- **llama-3.2-3b**: Meta's latest small model, modern architecture
- **gemma-2-2b**: Google's lightweight model, very fast

### Medium Models (4-8GB VRAM)
- **qwen2.5-7b**: High quality 7B model, excellent reasoning
- **mistral-7b**: Strong reasoning, good at following instructions
- **deepseek-coder-6.7b**: Specialized for code generation

## Quantization Options

Quantization affects model size, speed, and quality:

| Quantization | Size | Quality | Speed | Recommendation |
|-------------|------|---------|-------|----------------|
| Q2_K | Smallest | Lowest | Fastest | Emergency use only |
| Q3_K_S | Small | Decent | Fast | Low VRAM |
| Q3_K_M | Small | Good | Fast | Balanced 3-bit |
| Q4_K_M | Medium | Excellent | Fast | **Recommended default** |
| Q4_K_L | Medium | Very Good | Fast | High quality 4-bit |
| Q5_K_M | Large | Near-lossless | Medium | Best quality/size |
| Q6_K | Larger | Excellent | Medium | Very high quality |
| Q8_0 | Largest | Best | Slow | Maximum quality |

**Default**: `Q4_K_M` - Best balance of quality and file size

## Model Storage

Models are stored in: `~/llama.cpp/models/`

Files are named according to the HuggingFace repository format:
- `qwen2.5-3b-instruct-Q4_K_M.gguf`
- `Phi-3-mini-4k-instruct.Q4_K_M.gguf`

## Troubleshooting

### "llama.cpp not found"
Make sure you've cloned llama.cpp to `~/llama.cpp` and built it successfully.

### "llama-cli not found"
The build might have failed or llama-cli is in a different location. Check:
```bash
ls ~/llama.cpp/build/bin/
```

### Download fails
- Check your internet connection
- Some models require HuggingFace authentication. Set a token:
  ```bash
  export HF_TOKEN="your_token_here"
  ```
- Try a different quantization (some may not be available)

### Out of memory
- Use a smaller model
- Try a lower quantization (Q3_K_M instead of Q4_K_M)
- Reduce context size: `oi -m model-name -c 2048`

### Slow performance
- If you have a GPU, make sure llama.cpp was built with CUDA: `cmake -B build -DGGML_CUDA=ON`
- Check GPU is being used: `nvidia-smi` during chat
- Use a smaller model or lower quantization

## Customization

### Adding New Models

Edit `~/local_script/lib/models.json` to add your own models:

```json
{
  "id": "your-model-id",
  "name": "Your Model Name",
  "repo": "username/repo-name",
  "filename_template": "model-name-{quant}.gguf",
  "min_vram_gb": 4.0,
  "description": "Description of your model",
  "tags": ["tag1", "tag2"]
}
```

### Changing Defaults

Edit the `oi` script to change default values:
- `DEFAULT_QUANT="Q4_K_M"` - Default quantization
- `DEFAULT_CONTEXT=4096` - Default context size

## File Structure

```
~/local_script/
├── oi                    # Main executable script
├── README.md            # This documentation
└── lib/
    ├── hardware_detect.sh    # System detection
    └── models.json          # Model catalog

~/llama.cpp/
├── build/
│   └── bin/
│       └── llama-cli      # llama.cpp CLI tool
└── models/
    └── *.gguf            # Downloaded models
```

## How It Works

1. **Hardware Detection**: Checks GPU VRAM using `nvidia-smi`, RAM using `free`, and CPU cores using `nproc`
2. **Model Filtering**: Filters the model catalog to show only compatible models based on available memory
3. **Download**: Uses `curl` to download models from HuggingFace URLs
4. **Chat Launch**: Executes `llama-cli` with appropriate parameters for interactive chat

## License

This script follows the same license as llama.cpp (MIT License).

## Contributing

Contributions are welcome! Please ensure any changes follow the existing code style and include appropriate documentation.

## Acknowledgments

- [llama.cpp](https://github.com/ggml-org/llama.cpp) by Georgi Gerganov and contributors
- Model creators on HuggingFace
- The open-source LLM community
