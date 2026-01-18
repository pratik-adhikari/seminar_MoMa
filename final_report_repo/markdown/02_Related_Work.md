Here is the summary of the related work categorized by the gaps MoMa-LLM addresses:

### 2.1 3D Scene Graphs
- **Existing Approaches:** 3D scene graphs abstract dense maps into hierarchical, object-centric representations, with works like Hydra focusing on representing dynamically changing scenes [1]. Other approaches, such as ConceptGraphs and VoroNav, investigate zero-shot perception inputs for task planning [2].
- **MoMa-LLM Differentiation:** While previous works utilize scene graphs for reasoning, they have not realized object navigation using both dynamic and interactive scene graphs [3]. MoMa-LLM constructs open-vocabulary scene graphs dynamically from dense maps and Voronoi graphs, tightly interleaving them with an object-centric action space as the environment is explored [4].

### 2.2 LLMs for Planning
- **Existing Approaches:** Models like LLM-Planner use information retrieval for planning, while SayPlan focuses on identifying subgraphs within large, known scene graphs [5]. Most efforts focus on fully observed environments (e.g., table-top manipulation) or a priori explored scenes [6].
- **MoMa-LLM Differentiation:** Current methods struggle to generate grounded, executable plans for partially observed or unexplored environments [7]. MoMa-LLM addresses this by grounding LLMs in dynamically built graphs, enabling reasoning over long horizons in fully unexplored scenes where simple prompting strategies are insufficient [8].

### 2.3 Object Search
- **Existing Approaches:** Classical methods include frontier exploration and reinforcement learning, while recent semantic methods like ESC use language models to score frontiers based on object co-occurrences [9]. SayNav utilizes scene graphs but relies on non-interactive search and hardcoded heuristics for navigation [10].
- **MoMa-LLM Differentiation:** Unlike methods that rely on pairwise scoring or directional reasoning, MoMa-LLM treats search as a planning problem where the full scene is encoded jointly [11]. It specifically fills the gap of interactive search, allowing the agent to reason about manipulating the environment (e.g., opening doors or receptacles) to find objects that are not freely accessible [12].

### Structured Knowledge Representation in MoMa-LLM
To effectively use Large Language Models (LLMs) for robotic planning, MoMa-LLM converts complex 3D scene graphs into a structured textual format. This process bridges the gap between the robot's geometric understanding and the LLM's reasoning capabilities, focusing on three properties: grounding (adherence to physical reality), specificity (avoiding irrelevant context), and open-set reasoning (handling unknown semantics) [1].

The representation is composed of four key elements:

#### 1. Scene Structure Encoding
Rather than feeding raw data (like JSON) to the LLM, the system extracts a structured list of rooms and objects designed for compact text encoding [2].
- **Distance Abstraction:** Exact metric distances are binned and mapped to natural language adjectives (e.g., "near", "far") to facilitate easier reasoning for the LLM [3].
- **Object States:** The state of an object is encoded directly into its name (e.g., "opened door" or "closed fridge") to provide immediate context on interactability [4].
- **Summarization:** To keep the context concise, matching nodes are summarized with counters, and open doors that do not provide new connectivity are filtered out [5].

#### 2. Handling Partial Observability
Since the environment is initially unknown, the representation explicitly encodes "frontiers" (boundaries between explored and unexplored space) to enable exploration-exploitation reasoning [6].
- **Frontier Types:** The system differentiates between two types of unknown space:
    - "Unexplored Area": Space within a room (e.g., occluded space behind furniture) [7].
    - Leading Out: Frontiers that lead to entirely new areas or rooms, which are listed separately [8].
- **Affordances:** Instead of explicitly listing what every object can do, the system relies on the LLM to infer affordances (e.g., that a fridge can be opened) from the object descriptions and states [9].

#### 3. Dynamic History Realignment
To maintain a valid history in a constantly changing map (where a "living room" might later be reclassified as a "kitchen"), the system uses a novel realignment mechanism [10].
- **Position Tracking:** The system tracks the physical interaction positions of previous actions [11].
- **Retrospective Updates:** When constructing the prompt, previous actions are re-mapped to the current scene graph. For example, if a room was previously called "living room" but is now classified as "kitchen," the history will display `explore(kitchen)` instead of the original `explore(living room)` [12].

#### 4. Re-trial and Feedback
To handle failures without overwhelming the context window, the system provides simplified feedback.
- **State Feedback:** The LLM receives simple status updates like "success", "failure", or "invalid argument" [13].
- **Replanning:** If a command is syntactically invalid or infeasible, the LLM is prompted to try again immediately. If a physical action fails during execution, the scene is re-encoded with the new state, and the LLM makes a fresh decision [14].