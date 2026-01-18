### 3.1 Problem Statement
The authors address the challenge of embodied reasoning where a robotic agent must locate specific objects within large, unexplored, and human-centric environments [moma_llm]. To succeed, the agent must simultaneously perceive the environment to build a representation and reason about exploration and interaction (e.g., opening doors or drawers) to complete the task [moma_llm].

#### Formalization
The problem is formalized as a Partially Observable Markov Decision Process (POMDP), denoted as a tuple $\mathcal{M} = (S, A, O, T(s'|s, a), P(o|s), r(s, a))$ [moma_llm]. The components are defined as follows:
- **Goal ($g$):** A natural language description of the task the agent must complete [moma_llm].
- **State Space ($S$) & Action Space ($A$):** The underlying states and available actions for the agent [moma_llm].
- **Observation Space ($O$):** The agent's current observation $o$, consisting of a posed RGB-D frame $I_{t}$ [moma_llm].
- **Transition Probability ($T$):** Defined as $T(s'|s, a)$, representing the probability of moving from state $s$ to $s'$ given action $a$ [moma_llm].
- **Observation Probability ($P$):** Defined as $P(o|s)$, representing the likelihood of receiving observation $o$ in state $s$ [moma_llm].
- **Reward Function ($r$):** Defined as $r(s, a)$, providing feedback on the action taken [moma_llm].

#### Task: Semantic Interactive Object Search
The paper introduces the task of Semantic Interactive Object Search. In this scenario:
- **Objective:** The agent must find a target object category (e.g., a specific food item or tool) within an indoor environment [moma_llm].
- **Constraints:** The environment is initially unexplored, and objects may not be openly visible [moma_llm].
- **Interaction:** The task requires physical manipulation, such as opening doors to navigate through rooms and searching inside receptacles like cabinets and drawers to reveal hidden objects [moma_llm].
- **Success Condition:** The task is considered successful only if the agent observes an instance of the target category and explicitly executes the `done()` command [moma_llm].

#### Extension of Schmalstieg et al.
This work builds directly upon the "interactive search task" introduced by Schmalstieg et al. [himos]. The authors extend this baseline in several critical ways to increase complexity and realism:
- **Semantic vs. Random Placement:** While Schmalstieg et al. focused on random target placements, this work introduces a semantic variation [moma_llm]. The environment maintains realistic semantic co-occurrences (e.g., specific objects appearing near related objects), allowing the agent to use visible objects as cues to locate the target [moma_llm].
- **Scale and Complexity:** The task is expanded to include a much larger number of objects and receptacles compared to the restricted set used in the previous work [moma_llm].
- **Object Relations:** It incorporates a prior distribution of realistic room-object and object-object relations, meaning the presence of certain furniture or items informs the probability of the target's location [moma_llm].

### 3.2 Approach: MoMa-LLM
To enable high-level reasoning, we construct a hierarchical scene graph $\mathcal{G}_{S}$ that abstracts the environment into room and object-level entities, grounded by a fine-grained navigational graph. The construction process consists of three stages: dynamic mapping, topological graph generation, and semantic classification.

#### Dynamic RGB-D Mapping
The foundation of the scene representation is a semantic 3D map built from the robot's onboard perception.
- **Voxel Grid Construction:** The agent processes a stream of posed RGB-D frames $\{I_{0},...,I_{t}\}$ containing semantic information [moma_llm]. The point clouds from these frames are transformed into a global coordinate frame and arranged into a dynamic 3D voxel grid $\mathcal{M}_{t}$ [moma_llm]. This grid is updated continuously as the agent explores new areas or observes dynamic changes [moma_llm].
- **Occupancy Map:** To facilitate navigation, we derive a two-dimensional bird's-eye-view (BEV) occupancy map $\mathcal{B}_{t}$ from the 3D grid [moma_llm]. This is achieved by analyzing "stixels" (vertical columns of voxels) in $\mathcal{M}_{t}$; we identify the highest occupied entry per stixel to infer obstacle positions, walls, and explored free space $\mathcal{F}_{t}$ [moma_llm].

#### Voronoi Graph (GVD)
We abstract the dense metric map into a sparse topological graph $\mathcal{G_{V}}$ to support efficient navigation and spatial reasoning.
- **Computation:** We first inflate the obstacles in the BEV map $\mathcal{B}_{t}$ using a Euclidean Signed Distance Field (ESDF) to ensure robustness [moma_llm]. Based on this inflated map, we compute a Generalized Voronoi Diagram (GVD) [moma_llm]. The GVD consists of a set of points (nodes) that have equal clearance to the closest obstacles [moma_llm]. We filter this diagram by excluding nodes that are in the immediate vicinity of obstacles or outside the explored bounds $\mathcal{B}_{t}$ [moma_llm].
- **Navigation Utility:** The resulting nodes and edges form the navigational Voronoi graph $\mathcal{G_{V}}=(\mathcal{V},\mathcal{E})$ [moma_llm]. We extract the largest connected component to serve as the robot-centric navigation graph, sparsifying it to reduce the node count [moma_llm]. This graph allows the robot to navigate robustly by maximizing clearance from obstacles.

#### Scene Graph & Room Classification
The final layer, the 3D Scene Graph $\mathcal{G}_{S}$, clusters the Voronoi graph into semantic regions (rooms) and assigns objects to them.
- **Room Clustering (Door-Based Separation):** Unlike previous methods that rely on geometric constrictions (which fail in open layouts), we separate the global Voronoi graph $\mathcal{G}_{\mathcal{V}}$ into distinct room regions $\mathcal{G}_{\mathcal{V}}^{R}$ based on detected doors [moma_llm].
    - We model the probability distribution of observed door positions using a mixture of Gaussians: $\rho_{\mathcal{N}}(x,H)=\frac{1}{N_{D}}\sum_{i=1}^{N_{D}}K_{H}(x-x_{i})$, where $x_{i}$ are door coordinates and $H$ is the bandwidth matrix [moma_llm].
    - Edges and nodes of the Voronoi graph that fall into high-probability door regions are removed, effectively cutting the graph into disjoint components representing distinct rooms [moma_llm].
    - Connectivity between these rooms is re-established by calculating shortest paths between the disjoint components; if a path traverses exactly two components, they are marked as neighbors [moma_llm].
- **Object Assignment:** Objects are assigned to rooms by minimizing a weighted travel distance. For an object $o$, we identify the Voronoi node $n_{o}$ that minimizes the path length to the viewpoint $v_{p}$ from which the object was seen, weighted by the Euclidean distance to the object (Eq. 2 in the paper) [moma_llm]. This prevents erroneous assignments through walls [moma_llm].
- **LLM-Based Room Classification:** Once rooms are clustered and objects are assigned, we employ an LLM for open-set classification [moma_llm].
    - As shown in Fig. 3, the LLM is provided with a list of object categories contained within each room cluster (e.g., "armchairs, carpet, table-lamp" for room-0) [moma_llm].
    - The LLM analyzes these object compositions to infer the semantic room type (e.g., classifying room-0 as a "living room" and room-1 as a "bedroom") [moma_llm].
    - This classification is performed dynamically at each high-level policy step as the scene evolves [moma_llm].

#### Grounded High-Level Planning
The core contribution of MoMa-LLM lies in its ability to ground a Large Language Model (LLM) within a dynamically evolving scene graph. Rather than feeding raw data or unstructured lists to the model, the system extracts structured knowledge to bridge the gap between the robot's perception and the LLM's reasoning capabilities [moma_llm]. This process ensures the planning is grounded in physical reality, specific enough to avoid hallucinations, and open-set to handle unknown environments [moma_llm].

**The Prompt Design**
The text-based scene representation is wrapped in a carefully engineered prompt structure designed to elicit logical planning from the LLM. As illustrated in Fig. 4, the prompt consists of several distinct components [moma_llm]:
- **System & Task:** Clearly defines the agent's role (e.g., "You are a robot in an unexplored house") and the specific goal (e.g., "Find a stove") [moma_llm].
- **Skill API:** explicitly lists the available high-level function calls the robot can execute. These include `Maps(room, object)`, `go_to_and_open(room, object)`, `close(room, object)`, `explore(room)`, and `done()` [moma_llm].
- **Scene Context:** The structured knowledge extracted from the scene graph (as described above) is inserted here, detailing the current room, observed objects, and unexplored frontiers [moma_llm].
- **Analysis & Reasoning (Chain of Thought):** The prompt enforces a "Chain-of-Thought" process. It requires the LLM to first output an Analysis of where the target might be found and the necessary actions, followed by Reasoning to justify the specific next step, before finally generating the Command (function call) [moma_llm].

**Handling History with Dynamic Re-alignment**
A major challenge in dynamic scene graph planning is that the environment representation changes over time—rooms may be reclassified, or boundaries may shift as new areas are revealed [moma_llm]. This makes a static history of previous actions invalid or confusing.
MoMa-LLM addresses this via Dynamic Re-alignment:
- **Tracking Positions:** Instead of just memorizing the text of previous commands, the system tracks the physical interaction positions of past actions [moma_llm].
- **Re-mapping:** Before each new query to the LLM, the system re-aligns these past positions to the current state of the scene graph. It matches the old positions to the currently valid Voronoi nodes and room labels [moma_llm].
- **Example:** If the robot previously executed `explore(living room)`, but identifying a fridge later causes that area to be reclassified as a kitchen, the history presented to the LLM in the next step will automatically update to `explore(kitchen)` [moma_llm].
This ensures the LLM always acts on a consistent, up-to-date view of the world, preventing logical inconsistencies caused by the evolving map.
