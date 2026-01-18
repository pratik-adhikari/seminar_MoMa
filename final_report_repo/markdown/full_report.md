# Seminar Report: Language-Grounded Dynamic Scene Graphs for Interactive Object Search

**Student Name:** Pratik Adhikari  
**Date:** January 2026  
**Supervisor:** [Supervisor Name]  

## Abstract
To fully leverage mobile manipulation robots, agents must autonomously execute long-horizon tasks in large, unexplored environments [1]. This paper addresses the challenge of interactive object search, where robots must navigate, explore, and manipulate objects (e.g., opening doors and drawers) to find targets in partially observable settings [2]. We propose MoMa-LLM, a novel approach that grounds Large Language Models (LLMs) within structured representations derived from open-vocabulary scene graphs, which are dynamically updated during exploration [3]. By tightly interleaving these representations with an object-centric action space, the system achieves zero-shot, open-vocabulary reasoning [4]. To rigorously benchmark performance, we introduce a novel evaluation paradigm utilizing full efficiency curves and the Area Under the Curve for Efficiency (AUC-E) metric [5]. Extensive experiments in simulation and the real world demonstrate that MoMa-LLM substantially improves search efficiency compared to state-of-the-art baselines like HIMOS and ESC-Interactive [6].

---

## 1. Introduction

Interactive embodied AI tasks in large, human-centered environments require robots to reason over long horizons and interact with a multitude of objects [7]. In many real-world scenarios, these environments are a priori unknown or continuously rearranged, making autonomous operation significantly more difficult [8]. Specifically, the task of interactive object search presents unique challenges because objects are not always openly visible; they may be stored inside receptacles like cabinets or drawers, or located behind closed doors [9]. Consequently, an agent cannot rely on directional reasoning alone but must actively manipulate the environment—opening doors to navigate and searching through containers—to succeed [10].

**Key points to cover**
- Motivation for mobile manipulation in unexplored environments  
- Define the **Interactive Semantic Search** task (what the robot must do, under what uncertainty, and what counts as success)

Recent advancements have shown the potential of Large Language Models (LLMs) for generating high-level robotic plans [11]. However, existing methods such as SayCan or SayPlan are insufficient for interactive search in unexplored settings for several reasons:

- **Assumption of Full Observability:** Many prior works focus on fully observed environments, such as tabletop manipulation or pre-explored scenes [12].
- **Scalability and Hallucination:** In large, partially observable scenes with numerous objects, simply providing an LLM with raw observations or lists of objects increases the risk of generating impractical sequences or hallucinations [13]. Simple prompting strategies or raw JSON inputs of full scene graphs have proven insufficient for complex reasoning in these contexts [14].
- **Limited Scope:** Methods often restrict tasks to single rooms or rely on non-interactive navigation, failing to address the complexities of multi-room exploration and physical interaction [15].

To address these limitations, the authors propose MoMa-LLM, a method that grounds LLMs in dynamically built scene graphs [16]. This approach utilizes a scene understanding module that constructs open-vocabulary scene graphs from dense maps and Voronoi graphs as the robot explores [17]. By extracting structured and compact textual representations from these dynamic graphs, the system enables pre-trained LLMs to plan efficiently in partially observable environments [18]. This allows the robot to perform zero-shot, open-vocabulary reasoning, extending readily to a spectrum of complex mobile manipulation tasks [19].

---

## 2. Related Work

### 2.1 3D Scene Graphs
- **Hydra:** Represents the state-of-the-art in real-time 3D Scene Graph construction, abstracting geometry into topology and representing dynamically changing scenes [1].
- **Other:** Approaches like ConceptGraphs and VoroNav investigate zero-shot perception inputs for task planning [2].

### 2.2 LLMs for Planning
- **SayPlan:** Focuses on identifying subgraphs within large, known scene graphs for planning [5]. Most efforts focus on fully observed environments (e.g., table-top manipulation) or a priori explored scenes [6].
- **Other:** LLM-Planner and similar methods struggle to generate grounded, executable plans for partially observed or unexplored environments [7].

### 2.3 Object Search
- **ESC:** A baseline for exploration with soft commonsense constraints, scoring frontiers based on object co-occurrences [9].
- **Other:** Classical frontier exploration and reinforcement learning methods like HIMOS (which uses hierarchical RL) [10]. SayNav utilizes scene graphs but relies on non-interactive search and hardcoded heuristics for navigation.

---

## 3. Paper Summary

### 3.1 Problem Statement
The authors address the challenge of embodied reasoning where a robotic agent must locate specific objects within large, unexplored, and human-centric environments [1]. To succeed, the agent must simultaneously perceive the environment to build a representation and reason about exploration and interaction (e.g., opening doors or drawers) to complete the task [2].

**POMDP formulation (write explicitly)**
The problem is formalized as a Partially Observable Markov Decision Process (POMDP), denoted as a tuple $\mathcal{M} = (S, A, O, T, P, r)$:
- **S (States):** The complete state of the world, including robot pose, map, and object states (e.g., drawer open/closed) [3].
- **A (Actions):** Hybrid action space with high-level primitives (navigate, open) and low-level controllers [5].
- **O (Observations):** RGB-D images, robot pose, and semantic segmentations received by the agent [6].
- **T (Transition):** $T(s'|s, a)$ representing the probability of the state evolving from $s$ to $s'$ given action $a$ [7].
- **P (Observation model):** $P(o|s)$ representing the likelihood of receiving observation $o$ in state $s$ [8].
- **r (Reward):** Defined as $r(s, a)$, providing feedback on the action taken [9].

### 3.2 Approach: MoMa-LLM
To enable high-level reasoning, we construct a hierarchical scene graph $\mathcal{G}_{S}$ that abstracts the environment into room and object-level entities, grounded by a fine-grained navigational graph.

#### 3.2.1 Hierarchical 3D Scene Graph
The system builds a layered representation of the environment through dynamic mapping, topological graph generation, and semantic classification.

**Voronoi Graph Construction**
- **Computation:** We compute a Generalized Voronoi Diagram (GVD) from the inflated occupancy map. The GVD consists of points (nodes) that have equal clearance to the closest obstacles [8].
- **Navigation Utility:** The resulting nodes and edges form the navigational Voronoi graph $\mathcal{G_{V}}=(\mathcal{V},\mathcal{E})$. This graph allows the robot to navigate robustly by maximizing clearance from obstacles [10].

**Room Classification**
- **LLM Prompting:** The LLM is provided with a list of object categories contained within each room cluster (e.g., "armchairs, carpet, table-lamp" for room-0) [19].
- **Output Labels:** The LLM infers the semantic room type (e.g., classifying room-0 as a "living room" and room-1 as a "bedroom") [20].

#### 3.2.2 High-Level Action Space
**Actions (list explicitly)**
- `Maps(room, object)`: Navigate to a specific object or location.
- `go_to_and_open(room, object)`: Navigate to and interact with a container (e.g., fridge).
- `close(room, object)`: Close an opened container.
- `explore(room)`: Visit unexplored frontiers associated with a specific room.
- `done()`: Declare the task explicitly successful.

#### 3.2.3 Grounded High-Level Planning
The core contribution of MoMa-LLM lies in its ability to ground a Large Language Model (LLM) within a dynamically evolving scene graph [1].

**Scene Structure Encoding**
- The graph is serialized into a hierarchical list (Room -> Objects).
- Distances are binned into natural language adjectives ("near", "far") and object states are explicit ("closed fridge") [4].

**Partial Observability**
- **Frontiers:** Unknown space is explicitly represented as "Unexplored Area" (local) or "Leading Out" (global) nodes [6].
- **Replanning:** The prompt includes an "Analysis" and "Reasoning" step (Chain-of-Thought) before generating the next action command, with history dynamically realigned to the current map [16].

---

## 3.3 Experiments

### 3.3.1 Experimental Setup
- **Simulator:** iGibson (based on real-world scans) [1]
- **Robot (Sim):** Fetch mobile manipulator [2]
- **Robot (Real):** Toyota HSR [3]

### 3.3.2 Evaluation Metrics
- **Success Rate (SR):** Percentage of episodes where the target object is successfully found and `done()` is called.
- **SPL:** Success weighted by Path Length, measuring navigation efficiency.
- **AUC-E (Area Under Efficiency Curve):** A novel metric that plots success rates against varying time budgets, providing a robust measure of search efficiency independent of arbitrary cutoffs [8].

### 3.3.3 Results
**Simulation**
- **MoMa-LLM vs baselines:** MoMa-LLM achieved the highest Success Rate (97.7%), SPL (63.6), and AUC-E (87.2) [13].
- **Failure modes:** Primary failures were due to perception limitations or "infeasible actions" generated by the LLM when context was overwhelmed [15].

**Real-world Transfer**
- **Transfer capabilities:** The high-level reasoning transferred effectively to the real world (80% success rate) [18].
- **Latency and practical constraints:** Main constraints involved the computational latency of LLM queries and the reliance on specific detectors (like AR markers) to handle real-world perception noise [19].

---

## 4. Discussion

**Strengths**
- **Open-vocabulary reasoning:** Capable of handling novel room and object categories without retraining [1].
- **Structured reasoning with scene graphs:** Using scene graphs as a bridge allows the LLM to reason effectively about geometry and topology [2].
- **Robustness:** Demonstrated resilience to segmentation errors and real-world domain shifts [4].

**Limitations**
- **Perception dependency (garbage-in/garbage-out):** Heavily relies on ground-truth or high-quality semantics [5].
- **Latency (LLM calls, planning delays):** LLM queries dominate the runtime, and full graph re-computation scales poorly [9].
- **Cost blindness:** High-level planning decouples reasoning from low-level execution costs [12].

**Reproducibility**
- **Code availability:** The authors reference a project page, but specific release details for the full pipeline are limited [14].
- **Missing details:** Real-world failure analysis is constrained by limited feedback modalities [16].

---

## 5. Conclusion

MoMa-LLM establishes a robust standard for semantic grounding in exploration by treating the Scene Graph as a dynamic, structured prompt. By tightly interleaving high-level semantic reasoning with object-centric low-level policies, this approach allows mobile manipulation robots to effectively explore, navigate, and interact with large, initially unknown environments. The empirical validation of this approach—particularly the efficiency gains over RL baselines—marks a definitive shift towards hybrid neuro-symbolic architectures in embodied AI.

Through extensive evaluation in both simulation and the real world, MoMa-LLM significantly outperforms conventional heuristics, reinforcement learning methods, and unstructured LLM baselines in terms of search efficiency and decision-making capabilities. Future work lies in cost-aware grounding and integrating VLM-based room classification.

---

## References
1. Honerkamp et al., "Language-Grounded Dynamic Scene Graphs for Interactive Object Search with Mobile Manipulation," arXiv:2403.08605, 2024.
2. Schmalstieg et al., "Learning Long-Horizon Robot Exploration Strategies for Multi-Object Search," ICRA 2023.
3. Schmalstieg et al., "Learning Hierarchical Interactive Multi-Object Search for Mobile Manipulation (HIMOS)," IROS 2023.
4. Mohammadi et al., "MORE: Mobile Manipulation Rearrangement through Grounded Language Reasoning," 2025.
5. MoMa-LLM Project Page: https://moma-llm.cs.uni-freiburg.de/
6. Yang et al., "ESC: Exploration with Soft Commonsense Constraints for Zero-shot Object Navigation," ICRA 2023.
7. Hydra: Hughes et al., "Hydra: A Real-time Spatial Perception System for 3D Scene Graph Construction," RSS 2022.
8. SayPlan: Rana et al., "SayPlan: Grounding Large Language Models using 3D Scene Graphs," arXiv:2307.06135, 2023.
