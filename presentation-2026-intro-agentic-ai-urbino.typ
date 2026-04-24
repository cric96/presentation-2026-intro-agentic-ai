#import "@preview/touying:0.7.3": *
#import "themes/theme.typ": *
#import "@preview/ctheorems:1.1.3": *
#import "@preview/numbly:0.1.0": numbly
#import "utils.typ": *

#let fcite(key) = {
  footnote(numbering: "*")[#cite(key, form: "prose"), #cite(key, form: "full") #cite(key)]
}

// Pdfpc configuration
// typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc
#let pdfpc-config = pdfpc.config(
    duration-minutes: 30,
    start-time: datetime(hour: 14, minute: 10, second: 0),
    end-time: datetime(hour: 14, minute: 40, second: 0),
    last-minutes: 5,
    note-font-size: 12,
    disable-markdown: false,
    default-transition: (
      type: "push",
      duration-seconds: 2,
      angle: ltr,
      alignment: "vertical",
      direction: "inward",
    ),
  )

// Theorems configuration by ctheorems
#show: thmrules.with(qed-symbol: $square$)
#let theorem = thmbox(
  "theorem",
  "Theorem",
  fill: rgb("#23373b").lighten(95%),
  stroke: rgb("#23373b") + 0.5pt,
  radius: 0.5em,
  inset: (x: 1em, y: 1em),
)

#let definition(title: "Definition", body) = beamer-block(body, title: title, color: rgb("#23373b"))
#let example(title: "Example", body) = beamer-block(body, title: title, color: rgb("#008080"))
#let alert(title: "Alert", body) = beamer-block(body, title: title, color: rgb("#eb811b"))
#let corollary(title: "Corollary", body) = beamer-block(body, title: title, color: rgb("#23373b").lighten(20%))
#let proof = thmproof("proof", "Proof")

#show: theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  header-right: none,
  config-common(
    // handout: true,
    preamble: pdfpc-config,
  ),
  config-info(
    title: [Agentic AI],
    subtitle: [The architectural foundations of modern AI agents],
    author: author_list(
      (
        (first_author("Gianluca Aguzzi"), "gianluca.aguzzi@unibo.it"),
      )
    ),
    date: datetime.today().display("[day] [month repr:long] [year]"),
    institution: [University of Bologna],
    logo: align(right)[#image("images/disi.svg", width: 55%)],
  ),
)

#set text(font: ("Roboto", "DejaVu Sans", "Liberation Sans"), weight: 350, size: 20pt)
#show math.equation: set text(font: ("Roboto", "New Computer Modern Math", "DejaVu Sans Mono"))
#set strong(delta: 200)
#set par(justify: true)
#set highlight(fill: purple.lighten(80%))

#set raw(tab-size: 4)
#show raw.where(block: true): it => {
  if it.has("lang") and it.lang == "console" {
    block(
      fill: rgb("#1e1e1e"),
      inset: (x: 1em, y: 1em),
      radius: 0.7em,
      width: 100%,
      text(fill: rgb("#d4d4d4"), size: 0.65em, it)
    )
  } else {
    block(
      fill: luma(240),
      inset: (x: 1em, y: 1em),
      radius: 0.7em,
      width: 100%,
      text(size: 0.65em, it)
    )
  }
}

#show bibliography: set text(size: 0.75em)
#show footnote.entry: set text(size: 0.75em)

// #set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

== Outline

#highlight[_This presentation explores the *architectural foundations* of modern AI agents and how they are built today._]

=== Core Topics
- *What is an LLM agent?* — Defining _autonomy_, _reasoning_, and _tool use_.
- *Clarifying the terminology* — Agents/Tools/Open vs Closed LLMs/Memory.
- *Modern architectures* — LLMs as reasoning engines within complex loops.
- *Components & Patterns* — Memory, planning strategies, and _tool integration_.

=== Practical Side
- *Prompt Engineering* — techniques to _steer_ agent behavior.
- *Popular Frameworks* — A look at LangChain and its ecosystem.
- *Implementation Examples* — _Practical_ patterns for building your first agent.

_Code repository_: https://github.com/cric96/code-2026-intro-agentic-ai-urbino

== Who am I BTW?

#grid(
  columns: (auto, 1fr),
  column-gutter: 2em,
  align(center + horizon)[
    #let foto = image("images/myself.png")
    #box(
      foto,
      stroke: 2pt + black,
      height: 150pt,
      radius: 100%,
      clip: true,
    )
  ],
  align(left + horizon)[
    *Gianluca Aguzzi* -- Postdoc & Researcher @ UniBo

    #v(0.5em)

    #text(size: 0.9em)[
      - *Research*: Collective AI, Multi-Agent Learning, Self-Organizing Systems
        - *Recent Focus*: LLMs, Program Synthesis, AI-Assisted Development
      - *Teaching*: Advanced System Design and Modelling (ASDM), Programming and Development Paradigms
    ]

    #v(0.5em)

    #text(size: 0.85em, fill: gray)[
      📧 gianluca.aguzzi\@unibo.it \
      🌐 https://gianluca.aguzzi.dev/ \
      🐙 https://github.com/cric96
    ]
  ]
)


#focus-slide[
  But let's start with the basics!
]

== Everybody talks about _agents_

#align(center)[
  #box(width: 100%, height: 350pt)[
    #place(top + left, dx: 2%, dy: 0%, rotate(-4deg, image("images/openclaw-history.png", width: 30%)))
    #place(top + left, dx: 35%, dy: -5%, rotate(3deg, image("images/openclaw.png", width: 30%)))
    #place(top + left, dx: 68%, dy: 5%, rotate(-2deg, image("images/claude.png", width: 30%)))
    #place(top + left, dx: 5%, dy: 45%, rotate(4deg, image("images/copilot.png", width: 30%)))
    #place(top + left, dx: 38%, dy: 50%, rotate(-3deg, image("images/nature.png", width: 30%)))
    #place(top + left, dx: 65%, dy: 40%, rotate(5deg, image("images/new-york-time.png", width: 30%)))
  ]
]


== Why Now?

A positive feedback loop of *LLM capabilities* and *ecosystem maturity*:

=== Core LLM Advancements
- *Massive Contexts:* Processing 1M+ tokens allows agents to hold entire long histories in _memory_.
- *Native "Thinking":* Models use test-time compute to #underline[plan], #underline[explore], and #underline[self-correct] _before_ acting.
- *Tool-Awareness:* Models are explicitly _fine-tuned_ for reliable function calling and structured outputs (JSON).

=== Architectural Shifts
- Transition from rigid scripts to _dynamic_, _stateful_ workflows (e.g., LangGraph).
- #underline[Open standards] (like MCP) are solving the tool integration bottleneck.

=== Viable Economics
- Plunging inference costs and lower latency make complex, multi-step reasoning loops _fast_ and #underline[affordable].

  

== What is Agentic AI?

#definition(title: "Definition")[
  A broad paradigm or class of artificial intelligence systems designed not just to answer questions, but to pursue _complex goals_, _plan steps_, and take _autonomous_ actions in #underline[dynamic] environments.
]

- It represents a shift from purely *generative* AI (producing content) to *action-oriented* AI.
  - *Generative AI:* Creates new content based on prompts (e.g., writes a marketing campaign).
  - *Agentic AI:* Orchestrates actions using LLMs as a "brain" (e.g., distributes the campaign, monitors performance, and adjusts strategy).
- *Key Characteristics:*
  - *Goal-driven behavior:* Focuses on achieving outcomes over _multiple_ steps.
  - *Environmental awareness:* Can _observe_ and _interact_ with the #underline[surrounding] context.
  - *Autonomy:* Operates with _minimal_ human intervention.

== What is an LLM agent, BTW?

#definition(title: "LLM Agent")[
  An _LLM_ agent is a *specific implementation* of an AI agent. It is a software system that perceives its environment and processes information using an LLM as the _reasoning engine_. 
]

- *Agentic AI vs. AI Agents:*
  - *AI Agents* are the _building blocks_, focusing on specific tasks (like single tools in a toolbox).
  - *Agentic AI* is the broad system that coordinates multiple agents to handle complex workflows (using the tools to build a house).
  - An *LLM Agent* is the current, dominant _architecture_ to build these agents, using a #underline[Large Language Model] as its core brain.

- *Other AI Agents?*
  - You already know some non-LLM agents (es. RL agents, symbolic agents, etc.)

== The First Era: #underline[Copilots] and #underline[Chatbots]

=== Code generation: es. Copilot (_2021_)
- LLMs are used as *code generators* to assist developers in writing code.
- They have an index against the codebase, but initially lacked a persistent _memory_ of the conversation or the ability to autonomously #underline[reason] and #underline[act] across the codebase.

=== Chatbots: es. ChatGPT (_2022_)
- LLMs are used as *chatbots* to interact with users in a conversational manner.
- They maintain a conversation history, but initially lacked the ability to use #underline[tools] or access _external information_ beyond what they were trained on.

== Limitations of First Era LLM Systems

=== Knowledge cutoff
 LLMs are trained on data up to a _certain point in time_, which means they may not have access to the most #underline[recent information] or #underline[private data].
=== Hallucination
 Without enough _grounded_ context, LLMs try to #underline["guess"] the answer, which can lead to _confident but incorrect_ or _fabricated_ information.
 
=== Non-ergonomic workflows:
Interaction with LLMs can be inefficient. Users must manually _copy-paste outputs_, _run code_, or _chain tasks_ across different software.

#align(center)[
    *The Goal:* 
  #highlight[Can we make LLMs more _"agentic"_ by giving them #underline[tools], #underline[memory], and #underline[autonomy]?
  ]
]

== LLMs as the "Brain"

#definition(title: [Foundational Models#fcite(<foundationreasoning>)])[
  *LLMs* are trained on a vast _corpus of data_, enabling them to perform a wide range of tasks without #underline[task-specific training].
]

#example(title: "Traditional AI vs. Foundational Models")[
  *Traditional AI:* Trained on #underline[narrow] datasets for single, specific tasks (e.g., classification). _Rigid_ and require _retraining_.
  
  *Foundational Models:* Generalized understanding of _language_ and _logic_ allows performing diverse #underline[downstream] tasks (summarization, coding, reasoning).
]

== LLMs -- Nomenclature

=== Tokens
The fundamental _building blocks_ of text. Models are restricted and priced by token counts.

=== Context Window
The #underline[maximum tokens] processed in a single request. Acts as an agent's strict _short-term memory_.

=== Prompts
Instructions fed to the model. For agents, these include system rules, _tool definitions_, and conversation history.

=== Inference
The process of generating output. In agent loops, this happens _repeatedly_ (observe, reason, act).
== The Power of Zero-Shot Learning

#definition(title: [Zero-Shot Learning #fcite(<zeroshot>)])[
  Performing a task the model was _never trained on_, using #underline[only] a natural language prompt. No weight updates, no examples — _just instructions_.
]

#definition(title: [In-Context Reasoning])[
  The model _analyzes constraints_, _applies background knowledge_, and generates #underline[step-by-step solutions] — all within the prompt's context window.
]

#align(center)[

  *Key insight:*
  #highlight[Sufficiently large models exhibit emergent #underline[generalization] — they are not just pattern matchers, but can flexibly apply learned abstractions to entirely new   domains.]
]

== The Second Era: #underline[Agentic AI]

- The LLM is no longer just a _chatbot_; it acts as the #underline[controller] (or #underline[reasoning engine]) in a larger loop #fcite(<Plaat_2025>).
- It observes the state, decides what to do next, uses tools, and evaluates the outcome.
#align(center)[
  #image("images/react.png", width: 65%)
]

#focus-slide[
  Ok, now let's _break down_ the *core* components of an LLM agent!
]
== Agent Architecture: Core Components

A modern LLM agent consists of four main pillars built around the reasoning engine:

- *1. The "Brain" (LLM Provider):* The underlying model  that processes inputs and makes decisions.
- *2. Memory:* Systems for retaining _context_—from short-term / long-term memory.
- *3. Planning & Reasoning:* The logic (often guided by prompts) that breaks complex goals into actionable, sequential steps.
- *4. Tools & Actuators:* The interfaces  that allow the agent to affect the outside world.


#focus-slide[
  *#underline[LLM Providers]*: The "Brain" of the Agent
]
== LLM Providers
#definition(title: "Definition")[
  Software _interfacing with/managing_ LLMs (e.g., loading models) abstracting API calls, rate limits, and model management.
]

- *Two Major Categories:*
  - *Cloud-based APIs:* OpenAI, Anthropic, Cohere, etc.
  - *Local Runners / Open-source:* Ollama, vLLM, LocalAI.

- *De Facto Standard:*
  - Most providers expose models via a *REST API*.
  - #highlight[The *OpenAI API* is the industry standard for interfacing.]

== LLMs: Closed vs. Open

LLM can be understood as a *stack* of three core assets: #underline[Architecture],#underline[Weights], and #underline[Training Data]. 

#definition(title: "Closed Models")[
  Proprietary assets. Access only via API. 
  _Examples: GPT-4, Claude 3.5, Gemini._
]

#definition(title: "Open-Weight Models")[
  Architecture and weights are public. Anyone can deploy or modify them.
  _Examples: Llama Family, Gemma, Qwen_
]
#definition(title: "Open-Source Models")[
  Not just open-weights, but also *fully transparent* training data and pipelines.
  _Examples: Pythia, OLMo._
]
== LLMs: Open-Source Models - Why does it matters?


=== Control
Fine-tuning for specific _use-cases_ and #underline[adapting] behavior to your domain.
=== Privacy 
Run locally on private infrastructure — data _never_ leaves your environment.
=== Cost: 
No _pay-per-token_ (but you pay for compute!).
=== Transparency
Auditing for bias and behavior — inspect _weights_, _prompts_, and _outputs_.

== LLMs: Other Key Distinctions

#[
#set text(size: 0.75em)
#example(title: "Size")[
  - *Small (SLMs):* _Fast_, _low latency_, runnable on #underline[edge devices]/phones.
  - *Large (LLMs):* _High_ reasoning capacity, _complex logic_, requires high-end GPUs.
]

#example(title: "Specialization")[
  - *General:* Jack-of-all-trades (e.g., GPT-5.4, Claude Opus 4.6).
  - *Specialized:* Optimized for coding (GPT 5.3 Codex), math (DeepSeek-Math), or medicine (MedGemma) #fcite(<sellergren2026medgemmatechnicalreport>).
]

#example(title: "Precision:")[
  - *Full-Precision:* Maximum accuracy, but massive memory footprint.
  - *Quantized:* #fcite(<quantization>) Compressed weights (4-bit, 8-bit). Drastically faster with minimal loss.
]
]

== Not Just token predictions - Embedding Models

#definition(title: "Definition")[
  A specialized model that converts text (or images/audio) into *dense numerical vectors* (embeddings) in a high-dimensional space. Texts with similar meanings are mapped to vectors that are close to each other.
]

*Why are they useful for LLM Agents?*
- *Semantic Search:* Finding information based on meaning rather than exact keywords.
- *Retrieval-Augmented Generation (RAG):* An agent can embed a user's query, search a vector database for relevant context, and provide grounded answers.
- *Agent Memory:* Storing past interactions or facts as vectors, allowing the agent to "remember" and retrieve relevant past experiences dynamically.

#align(center)[
  #highlight[Embedding models allow agents to perform *semantic search* and maintain a *long-term memory*.]
]

== Provider Example: Ollama

#grid(
  columns: (auto, 1fr),
  column-gutter: 1em,
  align(center + horizon)[
    #box(
      image("images/ollama.png", width: 60pt, height: 60pt),
      stroke: 1.5pt + black,
      radius: 100%,
      clip: true,
    )
  ],
  align(left + horizon)[
    Ollama is an #underline[open-source]#footnote(("https://ollama.com/")) LLM provider that allows users to run and manage their own language models _locally_.
  ]
)

=== Installation & Usage
- Download and install Ollama from their official website.
- Pull a model: `ollama pull gemma4`
- Run the model: `ollama run gemma4`

=== Developer Ecosystem
- Exposes a *REST API* for programmatic interfacing.
- Native *Python/JS libraries* for easy integration into applications and agent frameworks.

== Interfacing via LLMs

- The *OpenAI API* has become the *de facto industry standard* for interfacing with LLMs — adopted not just by OpenAI, but by virtually every provider and local runner.

- *Key Endpoints:*
  - `POST /v1/chat/completions` — The core endpoint. Takes a list of *messages* (each with a `role` and `content`) and returns a generated response.
  - `POST /v1/embeddings` — Produces vector representations of text.
  - `GET /v1/models` — Lists available models.

#example(title: "List available models in Ollama")[
  Querying the models endpoint on a local Ollama instance:
  ```bash
  curl http://localhost:11434/v1/models
  ```
]

== Interfacing via LLMs: Example
```python
client = OpenAI(
    base_url="http://localhost:11434/v1/",
    api_key="ollama",  # required by the client, but ignored by Ollama
)
response = client.chat.completions.create(
    model="gemma4:e2b",
    messages=[{"role": "user", "content": "Explain what an LLM is."}],
)
```


=== Message Roles
- *`system`:* Developer instructions that shape the model's core behavior.
  - _"You need to respond in a formal tone and provide concise answers."_
- *`user`:* The query or instruction from the end-user.
  - _"What is the capital of France?"_
- *`assistant`:* Prior model responses, injected back to maintain multi-turn context (the foundation of _short-term memory_).
  - _"The capital of France is Paris."_

== Introducing Frameworks: _LangChain_

//To build Agentic systems without managing raw API calls and JSON manually, we use *Frameworks*.

#grid(
  columns: (auto, 1fr),
  column-gutter: 1em,
  align(center + horizon)[
    #box(
      image("images/langchain.png", width: 60pt, height: 60pt),
      stroke: 1.5pt + black,
      radius: 100%,
      clip: true,
    )
  ],
  align(left + horizon)[
    Langchain is a framework providing standard, _composable abstractions_ for *models*, *prompts*, *memory*, and *tools*#footnote(("https://langchain.com/")).
  ]
)

=== Why use a Framework?
- *Vendor Lock-in mitigation:* Switch between providers with a _single line of code_.
- *Unified Abstractions:* Consistent interfaces across the whole #underline[ecosystem] (prompts, tools, memory).

=== Langchain Ecosystem
- *`langchain`:* Core library for LLM interactions, abstractions, and memory.
- *`langgraph`:* Framework for building _dynamic_, _stateful_, and multi-actor agentic pipelines.
- *`langsmith`:* Platform for tracing, debugging, and evaluating LLM applications.

== Anatomy of a Prompt

#[
#set text(size: 0.9em)
#definition(title: [Prompt Engineering #fcite(<schulhoff2025promptreportsystematicsurvey>)])[
  The practice of _designing_, _structuring_, and _refining inputs_ (prompts) to effectively guide a foundational model towards generating a *desired*, *high-quality* output.
]
]
#[
#set text(size: 0.82em)
While we pass "messages" to the API, structurally, a _well-engineered_ prompt for an Agent typically consists of several distinct parts:

- *System Instructions:* The persona, rules, and core guidelines the agent must follow (aka _system prompt_).
- *Context / Grounding:* Relevant data (e.g., retrieved documents, conversation history, environment state) that #underline[grounds] the LLM (avoiding _hallucinations_).
- *User Query / Task:* The specific goal or question the user wants resolved.
- *Output Formatting:* Instructions on how to structure the output (e.g., JSON, markdown) to be parsed _programmatically_ by the agent loop.
#align(center)[
  #highlight[A well-engineered prompt is the *operating system* of the agent, defining its rules, context, and output format.]
]

]


== Prompting Strategies: Zero-Shot vs. Few-Shot

While *Zero-Shot* (giving instructions _without_ examples) is powerful, agents often require #underline[higher reliability] and stricter adherence to formats.

#definition(title: "Few-Shot Prompting")[
  Providing a #underline[few concrete examples] of the expected input and output directly in the prompt context _to condition_ the model's behavior.
]

*Why is Few-Shot crucial for Agents?*
- *Strict Formatting:* Ensures the model strictly adheres to complex output schemas (e.g., specific tool call formats, valid JSON).
- *Behavioral Details:* Demonstrates exactly how the agent should _react_ to #underline[edge cases], #underline[errors], or #underline[unclear user] queries.

== Prompting Strategies: Zero-Shot vs. Few-Shot

#example(title: "Few-Shot Example (LangChain)")[
```python
from langchain_core.prompts import ChatPromptTemplate, FewShotChatMessagePromptTemplate

examples = [
    {"input": "I love eating burgers and fries!", "output": "fast food"},
    {"input": "I enjoy a fresh salad with lots of veggies.", "output": "healthy food"},
]
example_prompt = ChatPromptTemplate.from_messages([
    ("user", "{input}"),
    ("assistant", "{output}"),
])
few_shot_prompt = FewShotChatMessagePromptTemplate(
    example_prompt=example_prompt,
    examples=examples,
)
```
]

== Eliciting Reasoning: Chain of Thought & "Thinking"

#[
#set text(size: 0.75em)
#definition(title: [Chain of Thought (CoT) #fcite(<cot>)])[
  A prompting technique where we explicitly ask the model to _"think step by step"_. By forcing the model to generate intermediate reasoning tokens, its final accuracy improves drastically.
]

#definition(title: [Native Thinking Models #fcite(<bandyopadhyay2025thinkingmachinessurveyllm>)])[
  Recent models internalize this process. They use *test-time compute* to autonomously plan, reason, and self-correct in a "thinking" phase #underline[before] returning the final output.
]

*Why it matters for Agents?*
- *Less Prompt Engineering:* You no longer need to heavily engineer the "reasoning step" in the prompt.
- *Inherent Planning:* The model inherently knows how to #underline[plan] and #underline[evaluate] its next actions.
]

== Example: The "Thinking" Phase

*User Query:* _"Which number is larger: 9.11 or 9.9?"_

#example(title: "Inside the model's test-time compute (Gemma 4 Think)")[
  ```text
  <think>
  1. The user wants to know if 9.11 is larger than 9.9.
  2. Let's compare the integer parts: both are 9.
  3. Let's compare the decimal parts: 0.11 vs 0.90.
  4. Since 0.90 > 0.11, 9.9 is larger.
  </think>
  9.9 is larger than 9.11.
  ```
]

During the `<think>` block, the model explores paths and #underline[self-corrects], drastically improving its reasoning capability #underline[before] taking an action.

== Structured Output

While asking an LLM to "output JSON" in the prompt is a start, it is prone to formatting errors and hallucinations.

#definition(title: "Structured Output")[
  A technique where the LLM is constrained at the API/provider level to respond _adhering strictly_ to a #underline[predefined schema] (like JSON Schema), rather than generating free-form text.
]

*Why is it fundamental in Agentic pipelines?*
- *Parsing Reliability:* Guarantees the output can be parsed #underline[programmatically] without crashing.
- *System Integration:* Essential for calling #underline[external APIs], saving to databases, or passing strictly typed arguments to tools.
- *Runtime Error Reduction:* Eliminates the need for complex regex parsing or #underline[brittle retry loops] to extract values.

```python
from pydantic import BaseModel, Field
from langchain_openai import ChatOpenAI

# 1. Define the expected schema using Pydantic
class SentimentResult(BaseModel):
    sentiment: str = Field(description="POSITIVE, NEGATIVE, or NEUTRAL")
    confidence: float = Field(ge=0.0, le=1.0)

llm = ChatOpenAI(
    model=model_name, 
    base_url=base_url,
    api_key="ollama", # Required but ignored
    temperature=0 # you want deterministic output for structured data
)

# 2. Bind the schema to the model
structured_llm = llm.with_structured_output(SentimentResult)

# 3. The output is directly a parsed Pydantic object!
result = structured_llm.invoke("This tool is incredibly useful.")
print(result.sentiment) # Output: POSITIVE
```

#focus-slide[
  *#underline[Memory]*: Let the Agent Remembers
]

== Memory: Are Agents Stateless or Stateful?

#[#set text(size: 0.87em)
By default, calling the LLM API is a #underline[stateless] operation — each call knows nothing about previous ones. Agents, however, need to #underline[remember]. Memory is what transforms isolated API calls into coherent, goal-directed behavior across multiple steps.
]
#[
#set text(size: 1em)
#definition(title: "Agent Memory")[
  The set of mechanisms that allow an agent to #underline[store], #underline[retrieve], and #underline[use] past information — whether within a single session or across many.
]
]

#align(center)[
  #highlight[Memory transforms isolated API calls into *coherent, goal-directed behavior* across multiple steps.]
]

*The core distinction lies in scope and persistence:*
- *Short-term memory (In-context):* Information held directly inside the active context window. Fast, immediate, but #underline[ephemeral] — it vanishes when the session ends.
- *Long-term memory (External):* Information persisted outside the model in a dedicated store (database, vector store). Survives across sessions and can #underline[scale beyond] any context window limit.


== Short-Term Memory: The Context Window

Short-term memory is simply the #underline[conversation history] injected into the prompt at each turn. The model "remembers" because past messages are literally re-sent with every new call.

#example(title: "How it works")[
  At each step, the agent prepends the full message history to the new user input. The LLM sees the entire conversation and can refer back to anything said earlier — as long as it fits within the #underline[context window].
]

#alert(title: "Key Limitation")[
  Context windows are finite. A long conversation or large retrieved documents will eventually #underline[overflow], forcing you to truncate or summarize older turns. This is not a bug — it is a #underline[fundamental architectural constraint].
]


== Short-Term Memory: A Minimal Implementation

```python
from langchain_ollama import ChatOllama
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage

class ShortTermMemory:
    def __init__(self, system_prompt: str, max_turns: int = 20):
        self._history: list = [SystemMessage(content=system_prompt)]
        self._max_turns = max_turns

    def add_user(self, content: str) -> None:
        self._history.append(HumanMessage(content=content))
        self._trim()

    def add_assistant(self, content: str) -> None:
        self._history.append(AIMessage(content=content))

    def _trim(self) -> None:
        # Keep system message + last max_turns pairs
        if len(self._history) > 1 + self._max_turns * 2:
            self._history = [self._history] + self._history[-(self._max_turns * 2):]

    @property
    def messages(self) -> list:
        return self._history
```

```python
class SimpleMemoryBasedAgent:
    def __init__(self, system_prompt: str, llm):
        self.memory = ShortTermMemory(system_prompt)
        self.llm = llm

    def interact(self, user_input: str) -> str:
        self.memory.add_user(user_input)
        response = self.llm.invoke(self.memory.messages)
        self.memory.add_assistant(response.content)
        return response.content
```
```python
agent = SimpleMemoryBasedAgent(
    system_prompt="You are a helpful assistant that remembers the conversation.",
    llm=ChatOllama(model="gemma4:e2b"),
)
while True:
    user_input = input("You: ")
    if user_input.lower() == "exit":
        print("Goodbye!")
        break
    response = agent.interact(user_input)
    print(f"Agent: {response}")
```


== Long-Term Memory: Persisting Beyond the Session

Long-term memory moves information #underline[outside] the model into a persistent external store that survives session boundaries #fcite(<survey-memory>).

=== Long-Term Memory Store
  An external system (e.g., #underline[vector database] or relational DB) queried at runtime to retrieve relevant facts, past interactions, or grounding documents.


=== Memory Types 
#[
#set text(size: 1em)
- *Semantic:* Vector search for similar chunks (for #underline[unstructured knowledge]).
- *Episodic:* Structured records retrievable by #underline[session ID] or timestamp.
- *Procedural:* Stored instructions conditioning behavior (e.g., #underline[user preferences]).
]


== Long-Term Memory: Retrieval-Augmented Generation (RAG) 

#image("images/rag.png")

#focus-slide[
  *#underline[Tools]*: Give the Agent Hands and Eyes
]

== How Agent Interacts with The World?

LLMs are fundamentally #underline[text generators] — they cannot directly interact with the external world. Tools bridge this gap.

#definition(title: "Tool")[
  An external function or service that an agent can #underline[call] to perform a specific action: fetching real-time data, running code, querying a database, or calling an API.
]

*A tool is formally defined by:*
- *Name:* Unique identifier (e.g., `get_current_time`).
- *Description:* What the tool does, in natural language.
- *Arguments Schema:* Structured definition of expected inputs (types, constraints).

#align(center)[
  #highlight[Tools transform LLMs from passive text generators into *active agents* that can #underline[perceive] and #underline[act] upon their environment.]
]

== How Tools Work: The ReAct Pattern

The most common pattern for tool use is *Reason + Act* (ReAct):

1. *Prompt Injection:* Tool descriptions and schemas are injected into the #underline[system prompt]
2. *Observe & Reason:* The LLM processes the query and decides to output a structured tool call.
3. *Halt Generation:* The LLM #underline[stops generating text] to wait for external execution.
4. *Act:* The agent framework *executes* the tool and captures the result.
5. *Resume & Respond:* The tool output is fed back as a new message, and the LLM resumes to generate the final answer.

=== Interaction Flow
  1. *System:* "Available tools: `get_current_time()`..."
  2. *User:* "What time is it?"
  3. *LLM (Thought):* "I need the time. Calling `get_current_time()`." *(Generation stops)*
  4. *Framework:* Executes tool → returns `"14:18"` back to the LLM.
  5. *LLM (Response):* "The current time is 14:18."


== Tools in LangChain

LangChain provides a clean abstraction to define and integrate tools:

```python
from langchain_core.tools import tool
import datetime

@tool
def get_current_time() -> str:
    """Returns the current time in HH:MM format."""
    return datetime.datetime.now().strftime("%H:%M")

@tool
def get_current_date() -> str:
    """Returns the current date in YYYY-MM-DD format."""
    return datetime.datetime.now().strftime("%Y-%m-%d")
```

Under the hood, `@tool` converts a function into a *StructuredTool* with:
- *Name* extracted from the function name.
- *Description* from the docstring.
- *Args Schema* inferred from type hints and Pydantic models.

== Using Tools in LangChain

Once defined, we #underline[bind] tools to the LLM. When prompted, the LLM will halt generation and return `tool_calls`.

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gemma4:e2b", base_url="http://localhost:11434/v1", temperature=0)
llm_with_tools = llm.bind_tools([get_current_time, get_current_date])
prompt = "What time is it and what is today's date?"
# With tools: LLM halts and requests tool execution
response = llm_with_tools.invoke(prompt)
for tool_call in response.tool_calls:
    print(f"- Tool Name: {tool_call['name']}")
    print(f"  Tool Args: {tool_call['args']}")
```

_Console Output_
```console
- Tool Name: get_current_time
  Tool Args: {}
- Tool Name: get_current_date
  Tool Args: {}
```

== The Tool Dilemma: Fragmentation

=== Problem
Each framework had its own proprietary way to define tools:
- OpenAI used JSON Schema.
- LangChain had its own format.
- Anthropic, Gemini, and others each had different standards.

=== Result
The "N x M" integration problem — developers had to reimplement the same tool for every framework.

#align(center)[
  #image("images/mcp.png", width: 90%)
]

== MCP: Model Context Protocol

#definition(title: "Definition")[
  An open standard (Anthropic) to define and share *context* — tools, resources, and prompts — across agents and frameworks.
]


Think of MCP as the *REST API* for AI agents:
- Like REST for web services, MCP standardizes how agents discover and invoke tools.

=== Architecture:
- *Host:* Needs context (e.g., Claude Desktop).
- *Server:* Provides context (e.g., a database, API).
- *Client:* Mediates between host and server.

This enables a *many-to-many* ecosystem without custom integrations.

== MCP in Practice

```python
from mcp.server.fastmcp import FastMCP
from datetime import datetime

mcp = FastMCP("Time")

@mcp.tool()
async def get_time(timezone: str = "local") -> str:
    """Get current time: 'local' (default) or 'UTC'."""
    tz = timezone.strip().lower()
    now = datetime.now(timezone.utc) if tz == "utc" else datetime.now()
    return now.isoformat(sep=" ", timespec="seconds")
```


#[
#set text(size: 0.9em)
=== Key benefits:
- *Write once, use everywhere:* The same MCP server works with Claude Desktop, LangChain agents, IDEs, and custom scripts.
- *Decoupled architecture:* Tool developers and agent developers work independently.
- *Transport agnostic:* Works over local stdio or remote HTTP/SSE.

_Deep dive:_ https://gianluca.aguzzi.dev/reading-group-2025-agentic-ai-and-mcp
]

#focus-slide[
  *#underline[Agents]*: Putting it All Together
]

== LangChain Agents

- Unified API which allow to describe all the components of an agent in a single place: model, tools, memory, and system prompt.


```python
# 1. Persistence layer for memory
memory = MemorySaver()
llm = build_local_chat_model()

# 2. Creating the agent with tools and memory
return create_agent(
    model=llm,
    tools=[draw_bar_chart, draw_pie_chart, draw_line_chart],
    system_prompt=(
        "You are an assistant specializing in data analysis and visualization. "
        "Choose the most appropriate drawing tool based on the request. "
        "You can answer questions about the previous context and reuse data."
    ),
    checkpointer=memory

```

#focus-slide[
  *Demo*
]

== Where Is This Going?

The agentic AI landscape is still moving fast, but a few directions are already becoming clear:

- *Multi-agent systems:* We are moving from single assistants to #underline[coordinated systems] with _handoffs_, _role specialization_, and _shared state_.
- *Planning as a first-class component:* Architectures are #underline[separating planning] from execution, making agents more _reliable_ and easier to _debug_.
- *Skills vs. MCP:* #underline[Skills] compress reusable behaviors and reduce prompt overhead; #underline[MCP] offers a more general interface for tools, resources, and external systems.
- *Agent ecosystems:* We are likely to see growing #underline[marketplaces] of reusable tools, skills, and domain-specific agents.

#align(center)[
  #highlight[Some of these trends are already visible today; what changes now is the speed of _adoption_ and _standardization_.]
]

== Takeaways

- *Agentic AI* is not just about generating text, but about pursuing goals through #underline[iterative reasoning] and #underline[action].
- *LLMs* provide the #underline[reasoning core], but they become useful agents only when combined with _memory_, _planning_, and _tools_.
- *Tools* give agents _access to the world_; #underline[MCP] makes that access #underline[interoperable] across frameworks and applications.
- *Frameworks* such as LangChain and LangGraph make these architectures _practical_ to build today.

  #highlight[We are moving from standalone chat interfaces to #underline[composable], #underline[stateful], #underline[tool-using] software systems.]


== Questions?

#align(center + horizon)[
  #set text(size: 1.2em)
  #grid(
    columns: (1fr),
    gutter: 1em,
    [*Thank you for your attention!*],
    [#text(size: 0.8em)[📧 #link("mailto:gianluca.aguzzi@unibo.it")]],
    [#text(size: 0.8em)[🌐 #link("https://gianluca.aguzzi.dev/")]],
    [#text(size: 0.8em)[🐙 #link("https://github.com/cric96")]]
  )
]

#place(top + left, dx: 2%, dy: 5%, rotate(-12deg, image("images/ollama.png", width: 120pt)))
#place(top + right, dx: -2%, dy: 10%, rotate(15deg, image("images/langchain.png", width: 120pt)))
#place(bottom + left, dx: 5%, dy: -5%, rotate(10deg, image("images/copilot.png", width: 120pt)))
#place(bottom + right, dx: -5%, dy: -8%, rotate(-15deg, image("images/claude.png", width: 150pt)))
#place(center + top, dy: 2%, rotate(5deg, image("images/mcp.png", width: 300pt)))
#place(center + bottom, dy: -2%, rotate(-5deg, image("images/react.png", width: 200pt)))

== Bibliography
#bibliography("bibliography.bib", title: none)

