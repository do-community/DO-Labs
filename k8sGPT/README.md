# K8sGPT + Claude MCP Setup Guide

```mermaid
graph TB
    subgraph "Your Kubernetes Cluster"
        K8s[🎯 Kubernetes<br/>Apps & Services]
        Problems[❌ Issues & Errors]
    end

    subgraph "K8sGPT Tools"
        Tools[🔧 K8sGPT Tools<br/>• Scan cluster<br/>• Find problems<br/>• Get cluster info]
    end

    subgraph "MCP Bridge"
        MCP[🌉 Model Context Protocol<br/>Connects Claude to K8sGPT]
    end

    subgraph "Claude AI"
        Claude[🤖 Claude<br/>Analyzes & Explains]
    end

    subgraph "You"
        User[👨‍💻 DevOps Engineer]
        Chat[💬 Chat with Claude]
    end

    %% Simple Flow
    User -->|"What's wrong with my cluster?"| Chat
    Chat --> Claude
    Claude -->|Uses MCP to call| MCP
    MCP --> Tools
    Tools -->|Scans| K8s
    K8s -->|Reports| Problems
    Problems --> Tools
    Tools -->|Returns data| MCP
    MCP --> Claude
    Claude -->|Explains issues & solutions| Chat
    Chat --> User

    %% Styling
    classDef k8s fill:#326ce5,stroke:#fff,stroke-width:2px,color:#fff
    classDef tools fill:#ff6b35,stroke:#fff,stroke-width:2px,color:#fff
    classDef mcp fill:#9b59b6,stroke:#fff,stroke-width:3px,color:#fff
    classDef claude fill:#d4af37,stroke:#fff,stroke-width:2px,color:#000
    classDef user fill:#28a745,stroke:#fff,stroke-width:2px,color:#fff

    class K8s,Problems k8s
    class Tools tools
    class MCP mcp
    class Claude claude
    class User,Chat user
```

## Quick K8sGPT Installation

Follow the K8sGPT installation guide: https://docs.k8sgpt.ai/getting-started/installation/

## MCP Support 

After K8sGPT installation, first check if it's working by using `k8sgpt analyze`. If it shows results, apply the commands below to start MCP support with Claude.

### Create the configuration directory if it doesn't exist
```bash
mkdir -p ~/Library/Application\ Support/Claude
```

### Create the configuration file
```bash
cat > ~/Library/Application\ Support/Claude/claude_desktop_config.json << EOF
{
  "mcpServers": {
    "k8sgpt": {
      "command": "k8sgpt",
      "args": ["serve", "--mcp", "--port", "3333"],
      "env": {
        "KUBECONFIG": "/Users/\$(whoami)/.kube/config"
      }
    }
  }
}
EOF
```

### Replace \$USER with your actual machine username
```bash
sed -i '' "s/\\\$USER/\$USER/g" ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

### Verify the configuration
```bash
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

## Usage

Once configuration is complete:

1. Restart Claude Desktop
2. Start chatting about your Kubernetes cluster
3. Claude will now have access to K8sGPT analysis capabilities

## Troubleshooting

- Ensure K8sGPT is properly installed and `k8sgpt analyze` works before configuring MCP
- Verify your `KUBECONFIG` path is correct
- Check that port 3333 is available
- Restart Claude Desktop after making configuration changes
