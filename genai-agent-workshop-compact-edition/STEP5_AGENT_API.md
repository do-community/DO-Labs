# Step 5 (Optional): Calling Your Recruiter AI Agent Using an API

In this final exercise, you will learn how to interact with your AI Agent via an API call. This enables you to programmatically send queries to your AI Agent and retrieve responses. A pre-configured Python script (`agent.py`) is provided in the GitHub repository to simplify this process.

## Prerequisites

Before proceeding, ensure you have:

- Python 3.7 or later installed.
- (Optional, but highly recommended) A virtual environment like [conda](https://docs.anaconda.com/miniconda/install/#quick-command-line-install) or [venv](https://docs.python.org/3/library/venv.html).
- The `agent.py` script, available in the repository under `recruiter-walkthrough/agent.py`.
- Installed the required Python libraries: `pyjwt`, `openai`, and `httpx`.

  ```bash
  pip install pyjwt openai httpx
  ```

- Your AI Agent's credentials:

  - Agent Key: Found in your chatbot embed code under `data-chatbot-id`.
  - Agent Endpoint URL: Found in your chatbot embed code (src value in the embed script).

## 5.1: Update agent.py

1. Open the `agent.py` file in a text editor. This Python file is located in the `recruiter-walkthrough` directory in this repo.
2. Replace the placeholders with your agent's details:

  - `agent_key`: Replace `<your-agent-endpoint-key>` with your Agent Key.
  - `agent_endpoint`: Replace `<your-agent-endpoint-url>` with your Agent Endpoint URL. Ensure it ends with /api/v1/.

## 5.2: Test the Script

1. Run the script:

  ```bash
  python agent.py
  ```

2. The script will send a query to your Agent. The default query is:

    ```
    What are the best practices for screening software engineering candidates?
    ```

3. The agent's response will be printed to the terminal.

### How the Script Works

The API Endpoint that is deployed is OpenAI API compatible. Most LLMs these days are OpenAI compatible and these Agents aren't any different.

## 5.3: Customize the Script

1. Modify the messages parameter in the script to include your desired query:

  ```python
  messages=[{"role": "user", "content": "Your custom query here"}]
  ```

2. Adjust the response handling as needed.

## Next Steps...

Let's wrap up here...

→ [Next Up: Concluding Remarks](./FINISH.md)
