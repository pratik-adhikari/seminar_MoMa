Here is the summary of the related work categorized by the gaps MoMa-LLM addresses:

### 2.1 3D Scene Graphs
- **Hydra:** Represents the state-of-the-art in real-time 3D Scene Graph construction, abstracting geometry into topology [hydra]. It focuses on representing dynamically changing scenes through a hierarchical representation.
- **Other:** Approaches like ConceptGraphs [conceptgraphs] and VoroNav [voronav] investigate zero-shot perception inputs for task planning.
- **MoMa-LLM Differentiation:** While previous works utilize scene graphs for reasoning, they have not realized object navigation using both dynamic and interactive scene graphs [moma_llm]. MoMa-LLM constructs open-vocabulary scene graphs dynamically from dense maps and Voronoi graphs, tightly interleaving them with an object-centric action space as the environment is explored [moma_llm].

### 2.2 LLMs for Planning
- **SayPlan:** Focuses on identifying subgraphs within large, known scene graphs for planning [sayplan]. However, it assumes a fully explored environment.
- **SayCan:** Grounds LLMs in robotic affordances but focuses on fully observed table-top settings [saycan].
- **MoMa-LLM Differentiation:** Current methods struggle to generate grounded, executable plans for partially observed or unexplored environments [moma_llm]. MoMa-LLM addresses this by grounding LLMs in dynamically built graphs, enabling reasoning over long horizons in fully unexplored scenes where simple prompting strategies are insufficient [moma_llm].

### 2.3 Object Search
- **ESC:** Exploration with Soft Commonsense Constraints uses language models to score frontiers based on object co-occurrences [esc].
- **HIMOS:** A hierarchical reinforcement learning approach for interactive search, which serves as a strong baseline [himos].
- **MoMa-LLM Differentiation:** Unlike methods that rely on pairwise scoring or directional reasoning, MoMa-LLM treats search as a planning problem where the full scene is encoded jointly [moma_llm]. It specifically fills the gap of interactive search, allowing the agent to reason about manipulating the environment (e.g., opening doors or receptacles) to find objects that are not freely accessible [moma_llm].

### Structured Knowledge Representation in MoMa-LLM
To effectively use Large Language Models (LLMs) for robotic planning, MoMa-LLM converts complex 3D scene graphs into a structured textual format. This process bridges the gap between the robot's geometric understanding and the LLM's reasoning capabilities, focusing on three properties: grounding (adherence to physical reality), specificity (avoiding irrelevant context), and open-set reasoning (handling unknown semantics) [moma_llm].

The representation is composed of four key elements:

#### 1. Scene Structure Encoding
Rather than feeding raw data (like JSON) to the LLM, the system extracts a structured list of rooms and objects designed for compact text encoding [moma_llm].
- **Distance Abstraction:** Exact metric distances are binned and mapped to natural language adjectives (e.g., "near", "far") to facilitate easier reasoning for the LLM [moma_llm].
- **Object States:** The state of an object is encoded directly into its name (e.g., "opened door" or "closed fridge") to provide immediate context on interactability [moma_llm].
- **Summarization:** To keep the context concise, matching nodes are summarized with counters, and open doors that do not provide new connectivity are filtered out [moma_llm].

#### 2. Handling Partial Observability
Since the environment is initially unknown, the representation explicitly encodes "frontiers" (boundaries between explored and unexplored space) to enable exploration-exploitation reasoning [moma_llm].
- **Frontier Types:** The system differentiates between two types of unknown space:
    - "Unexplored Area": Space within a room (e.g., occluded space behind furniture) [moma_llm].
    - Leading Out: Frontiers that lead to entirely new areas or rooms, which are listed separately [moma_llm].
- **Affordances:** Instead of explicitly listing what every object can do, the system relies on the LLM to infer affordances (e.g., that a fridge can be opened) from the object descriptions and states [moma_llm].

#### 3. Dynamic History Realignment
To maintain a valid history in a constantly changing map (where a "living room" might later be reclassified as a "kitchen"), the system uses a novel realignment mechanism [moma_llm].
- **Position Tracking:** The system tracks the physical interaction positions of previous actions [moma_llm].
- **Retrospective Updates:** When constructing the prompt, previous actions are re-mapped to the current scene graph. For example, if a room was previously called "living room" but is now classified as "kitchen," the history will display `explore(kitchen)` instead of the original `explore(living room)` [moma_llm].

#### 4. Re-trial and Feedback
To handle failures without overwhelming the context window, the system provides simplified feedback.
- **State Feedback:** The LLM receives simple status updates like "success", "failure", or "invalid argument" [moma_llm].
- **Replanning:** If a command is syntactically invalid or infeasible, the LLM is prompted to try again immediately. If a physical action fails during execution, the scene is re-encoded with the new state, and the LLM makes a fresh decision [moma_llm].