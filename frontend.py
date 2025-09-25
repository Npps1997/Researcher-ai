import streamlit as st
from ai_researcher import INITIAL_PROMPT, chatbot, retrieve_all_threads
from pathlib import Path
import logging
from langchain_core.messages import AIMessage, HumanMessage
import uuid

# Basic app config
st.set_page_config(page_title="Researcher AI", page_icon="📄")
st.title("📄 Researcher AI")


# *****************************Utitly Functions********************************

def generate_thread_title():
    """Generate sequential chat titles like Chat 1, Chat 2, etc."""
    return f"Chat {len(st.session_state['chat_threads']) + 1}"


def reset_chat():
    """Start a new chat session with a sequential title."""
    thread_title = generate_thread_title()
    st.session_state['thread_id'] = thread_title
    add_thread(st.session_state['thread_id'])
    st.session_state['chat_history'] = []


def add_thread(thread_id):
    if thread_id not in st.session_state['chat_threads']:
        st.session_state['chat_threads'].append(thread_id)

def load_conversation(thread_id):
    return (chatbot.get_state(config={"configurable": {"thread_id": thread_id}})).values["messages"]



# ****************************Logging and Session State Setup********************************

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize session state
if "chat_history" not in st.session_state:
    st.session_state.chat_history = []
    logger.info("Initialized chat history")

if "pdf_path" not in st.session_state:
    st.session_state.pdf_path = None

if "thread_id" not in st.session_state:
    st.session_state.thread_id = "Chat 1"

if "chat_threads" not in st.session_state:
    st.session_state.chat_threads = retrieve_all_threads()
    if not st.session_state.chat_threads:
        st.session_state.chat_threads = ["Chat 1"]

add_thread(st.session_state['thread_id'])

# ************************************SideBar************************************

st.sidebar.title("Research AI Agent")

if st.sidebar.button("New Chat"):
    reset_chat()

st.sidebar.header("My conversation")

for thread_id in st.session_state['chat_threads'][::-1]:
    if st.sidebar.button(str(thread_id)):
        st.session_state['thread_id'] = thread_id
        messages = load_conversation(thread_id)

        temp_messages = []

        for msg in messages:
            if isinstance(msg, HumanMessage):
                role='user'
            else:
                role='assistant'
            temp_messages.append({'role': role, 'content': msg.content})

        st.session_state['chat_history'] = temp_messages



# ************************************Main UI************************************

# loading the conversation history
for message in st.session_state['chat_history']:
    with st.chat_message(message['role']):
        st.text(message['content'])

# Chat interface
user_input = st.chat_input("What research topic would you like to explore?")

if user_input:
    # Log and display user input
    logger.info(f"User input: {user_input}")
    st.session_state.chat_history.append({"role": "user", "content": user_input})
    st.chat_message("user").write(user_input)

    # Prepare input for the agent-
    chat_input = {"messages": [{"role": "system", "content": INITIAL_PROMPT}] + st.session_state.chat_history}
    logger.info("Starting agent processing...")

    
    CONFIG = {'configurable': {'thread_id': st.session_state["thread_id"]}}

    # Stream agent response
    full_response = ""
    for s in chatbot.stream(chat_input, CONFIG, stream_mode="values"):
        message = s["messages"][-1]
        
        # Handle tool calls (log only)
        if getattr(message, "tool_calls", None):
            for tool_call in message.tool_calls:
                logger.info(f"Tool call: {tool_call['name']}")
        
        # Handle assistant response
        if isinstance(message, AIMessage) and message.content:
            text_content = message.content if isinstance(message.content, str) else str(message.content) 
            full_response += text_content + " "
            st.chat_message("assistant").write(full_response)
            

    # Add final response to history
    if full_response:
        st.session_state.chat_history.append({"role": "assistant", "content": full_response})