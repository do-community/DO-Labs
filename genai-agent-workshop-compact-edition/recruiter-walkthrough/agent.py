# Install OpenAI libraries.
from openai import OpenAI

# Make sure to set these values as environment variables.
agent_endpoint = "<your-agent-endpoint-url>" + "/api/v1/"  # replace with your agent's endpoint URL and make sure to keep the "/api/v1" suffix.
agent_key = "<your-agent-endpoint-key>"  # replace with your agent's endpoint key.

if __name__ == "__main__":
    client = OpenAI(
        base_url = agent_endpoint,
        api_key = agent_key,
    )

    response = client.chat.completions.create(
        model = "n/a",
        messages = [{"role": "user", "content": "What are the best practices for screening software engineering candidates?"}],
    )

    for choice in response.choices:
        print(choice.message.content) 
 