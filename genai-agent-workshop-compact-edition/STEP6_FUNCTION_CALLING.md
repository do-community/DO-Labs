# Step 6: (Optional) Adding Function Calling to the Recruiter AI Agent

In this section, we'll enhance the Recruiter AI Agent by adding a DigitalOcean function that uses the **function calling** feature of the GenAI platform. The function will take a job title and experience level as input and return a mock list of suitable interview questions.

## 6.1: Create the Function Using the DigitalOcean Control Panel

To create the function:

1. Log in to your DigitalOcean account and navigate to the [Functions](https://cloud.digitalocean.com/functions) section.

2. Click **Create Function** and configure the function:

   - **Name**: `get-interview-questions`
   - **Runtime**: Select the preferred runtime (e.g., Node.js or Python).
   - **Trigger**: Select **HTTP Trigger** to allow the function to be called via a URL.

3. In the function editor, implement the logic to:
   - Accept the job title and experience level as input (e.g., in JSON format).
   - Return a curated list of interview questions (e.g., as a JSON array).

4. Save and deploy the function.

5. After deployment, note the function's HTTP endpoint URL for later use.

## 6.2: Integrate the Function with the AI Agent

1. Navigate to the **AI Agents** section in the GenAI Platform.
2. Select your AI Agent (`RecruiterAgent`).
3. Go to the **Function Calling** tab and click **Add Function**.
4. Provide the following details:

   - **Function Name**: `getInterviewQuestions`
   - **Endpoint URL**: Paste the HTTP URL of the function created earlier.
   - **Input Format**: Specify the input parameters in JSON format. Example:

     ```json
     {
       "jobTitle": "string",
       "experienceLevel": "string"
     }
     ```

   - **Output Format**: Define the expected output format in JSON. Example:

     ```json
     {
       "questions": [
         {
           "category": "Technical",
           "question": "string",
           "expectedOutcome": "string"
         },
         {
           "category": "Behavioral",
           "question": "string",
           "expectedOutcome": "string"
         }
       ]
     }
     ```

5. Test the function integration:

   - Use the **Test Function** option in the GenAI dashboard to ensure the function responds correctly to sample inputs.

6. Enable the function for the AI Agent by saving the configuration.

## 6.3: Test the AI Agent with Function Calling

1. Navigate to the **Playground** for the AI Agent.
2. Input a query that triggers the function call. Example:

   - "Generate interview questions for a Senior Software Engineer position."
   
3. Verify that the AI Agent uses the function to fetch and return appropriate interview questions.

With this integration, your Recruiter AI Agent is now equipped to provide dynamic, role-specific interview questions, enhancing its capabilities as a recruitment assistant.

## Next Steps...

→ [Next Up: Concluding Remarks](./FINISH.md)
