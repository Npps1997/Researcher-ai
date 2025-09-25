# Step1: Define state
from typing import TypedDict
from typing import Annotated, Literal
from langgraph.graph.message import add_messages
from dotenv import load_dotenv

# Step2: Define ToolNode & Tools
from arxiv_tool import *
from read_pdf_tool import *
from write_pdf_tool import *
from langgraph.prebuilt import ToolNode


load_dotenv()

class State(TypedDict):
    messages: Annotated[list, add_messages]


tools = [arxiv_search, read_pdf, render_latex_pdf]
tool_node = ToolNode(tools)


# Step3: Setup LLM
import os
from langchain_groq import ChatGroq
from langchain_google_genai import ChatGoogleGenerativeAI

model = ChatGoogleGenerativeAI(model="gemini-2.5-flash", api_key=os.getenv("GOOGLE_API_KEY")).bind_tools(tools)
model = model.bind_tools(tools)

# Step4: Setup graph

from langgraph.graph import END, START, StateGraph

def call_model(state: State):
    """LLM node that may answer or request a tool call."""
    messages = state["messages"]
    response = model.invoke(messages)
    return {"messages": [response]}


def should_continue(state: State) -> Literal["tools", END]:
    messages = state["messages"]
    last_message = messages[-1]
    if last_message.tool_calls:
        return "tools"
    return END

# GRAPH

workflow = StateGraph(State)
workflow.add_node("agent", call_model)
workflow.add_node("tools", tool_node)
workflow.add_edge(START, "agent")
workflow.add_conditional_edges("agent", should_continue)
workflow.add_edge("tools", "agent")

# CHECKPOINTER

from langgraph.checkpoint.sqlite import SqliteSaver
import sqlite3

conn = sqlite3.connect(database = "researcher.db", check_same_thread = False)
checkpointer = SqliteSaver(conn = conn)

chatbot = workflow.compile(checkpointer=checkpointer)

# Step5: TESTING
INITIAL_PROMPT = """
You are an expert researcher in the fields of physics, mathematics,
computer science, quantitative biology, quantitative finance, statistics,
electrical engineering and systems science, and economics.

You are going to analyze recent research papers in one of these fields in
order to identify promising new research directions and then write a new
research paper. For research information or getting papers, ALWAYS use arxiv.org.
You will use the tools provided to search for papers, read them, and write a new
paper based on the ideas you find.

To start with, have a conversation with me in order to figure out what topic
to research. Then tell me about some recently published papers with that topic.
Once I've decided which paper I'm interested in, go ahead and read it in order
to understand the research that was done and the outcomes.

Pay particular attention to the ideas for future research and think carefully
about them, then come up with a few ideas. Let me know what they are and I'll
decide what one you should write a paper about.

Finally, I'll ask you to go ahead and write the paper. Make sure that you
include mathematical equations in the paper. Once it's complete, you should
render it as a LaTeX PDF. Make sure that TEX file is correct and there is no error in it so that PDF is easily exported. When you give papers references, always attatch the pdf links to the paper"""


# HELPER FUNCTION

def retrieve_all_threads():
    all_threads = set()
    for checkpoint in checkpointer.list(None):
        all_threads.add(checkpoint.config['configurable']['thread_id'])

    return list(all_threads)

# test

# def print_stream(stream):
#     for s in stream:
#         message = s["messages"][-1]
#         print(f"Message received: {message.content[:200]}...")
#         message.pretty_print()

# CONFIG = {'configurable': {'thread_id': 'thread_1'}}
# from langchain_core.messages import HumanMessage, AIMessage
# response = chatbot.invoke({"messages": HumanMessage(content="What is my name")}, CONFIG)

# print(response)

