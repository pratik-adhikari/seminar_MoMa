# Seminar Report: Language-Grounded Dynamic Scene Graphs for Interactive Object Search

**Student Name:** Pratik Adhikari  
**Date:** January 2026  
**Supervisor:** [Supervisor Name]  

## Abstract
To fully leverage mobile manipulation robots, agents must autonomously execute long-horizon tasks in large, unexplored environments [moma_llm]. This paper addresses the challenge of interactive object search, where robots must navigate, explore, and manipulate objects (e.g., opening doors and drawers) to find targets in partially observable settings [moma_llm]. We propose MoMa-LLM, a novel approach that grounds Large Language Models (LLMs) within structured representations derived from open-vocabulary scene graphs, which are dynamically updated during exploration [moma_llm]. By tightly interleaving these representations with an object-centric action space, the system achieves zero-shot, open-vocabulary reasoning [moma_llm]. To rigorously benchmark performance, we introduce a novel evaluation paradigm utilizing full efficiency curves and the Area Under the Curve for Efficiency (AUC-E) metric [moma_llm]. Extensive experiments in simulation and the real world demonstrate that MoMa-LLM substantially improves search efficiency compared to state-of-the-art baselines like HIMOS and ESC-Interactive [moma_llm].

---

## 1. Introduction

Interactive embodied AI tasks in large, human-centered environments require robots to reason over long horizons and interact with a multitude of objects [moma_llm]. In many real-world scenarios, these environments are a priori unknown or continuously rearranged, making autonomous operation significantly more difficult [moma_llm]. Specifically, the task of interactive object search presents unique challenges because objects are not always openly visible; they may be stored inside receptacles like cabinets or drawers, or located behind closed doors [moma_llm]. Consequently, an agent cannot rely on directional reasoning alone but must actively manipulate the environment—opening doors to navigate and searching through containers—to succeed [himos].

**Key points to cover**
- Motivation for mobile manipulation in unexplored environments  
- Define the **Interactive Semantic Search** task (what the robot must do, under what uncertainty, and what counts as success)

Recent advancements have shown the potential of Large Language Models (LLMs) for generating high-level robotic plans [saycan]. However, existing methods such as SayCan or SayPlan are insufficient for interactive search in unexplored settings for several reasons:

- **Assumption of Full Observability:** Many prior works focus on fully observed environments, such as tabletop manipulation or pre-explored scenes [sayplan].
- **Scalability and Hallucination:** In large, partially observable scenes with numerous objects, simply providing an LLM with raw observations or lists of objects increases the risk of generating impractical sequences or hallucinations [moma_llm]. Simple prompting strategies or raw JSON inputs of full scene graphs have proven insufficient for complex reasoning in these contexts [moma_llm].
- **Limited Scope:** Methods often restrict tasks to single rooms or rely on non-interactive navigation, failing to address the complexities of multi-room exploration and physical interaction [himos].

To address these limitations, the authors propose MoMa-LLM, a method that grounds LLMs in dynamically built scene graphs [moma_llm]. This approach utilizes a scene understanding module that constructs open-vocabulary scene graphs from dense maps and Voronoi graphs as the robot explores [moma_llm]. By extracting structured and compact textual representations from these dynamic graphs, the system enables pre-trained LLMs to plan efficiently in partially observable environments [moma_llm]. This allows the robot to perform zero-shot, open-vocabulary reasoning, extending readily to a spectrum of complex mobile manipulation tasks [moma_llm].

---

## 2. Related Work

### 2.1 3D Scene Graphs
- **Hydra:** Represents the state-of-the-art in real-time 3D Scene Graph construction, abstracting geometry into topology and representing dynamically changing scenes [hydra].
- **Other:** Approaches like ConceptGraphs and VoroNav investigate zero-shot perception inputs for task planning [conceptgraphs, voronav].

### 2.2 LLMs for Planning
- **SayPlan:** Focuses on identifying subgraphs within large, known scene graphs for planning [sayplan]. Most efforts focus on fully observed environments (e.g., table-top manipulation) or a priori explored scenes [saycan].
- **Other:** LLM-Planner and similar methods struggle to generate grounded, executable plans for partially observed or unexplored environments [moma_llm].

### 2.3 Object Search
- **ESC:** A baseline for exploration with soft commonsense constraints, scoring frontiers based on object co-occurrences [esc].
- **Other:** Classical frontier exploration and reinforcement learning methods like HIMOS (which uses hierarchical RL) [himos]. SayNav utilizes scene graphs but relies on non-interactive search and hardcoded heuristics for navigation.

---

## 3. Paper Summary

### 3.1 Problem Statement
The authors address the challenge of embodied reasoning where a robotic agent must locate specific objects within large, unexplored, and human-centric environments [moma_llm]. To succeed, the agent must simultaneously perceive the environment to build a representation and reason about exploration and interaction (e.g., opening doors or drawers) to complete the task [moma_llm].

**POMDP formulation (write explicitly)**
The problem is formalized as a Partially Observable Markov Decision Process (POMDP), denoted as a tuple $\mathcal{M} = (S, A, O, T, P, r)$:
- **S (States):** The complete state of the world, including robot pose, map, and object states (e.g., drawer open/closed) [moma_llm].
- **A (Actions):** Hybrid action space with high-level primitives (navigate, open) and low-level controllers [moma_llm].
- **O (Observations):** RGB-D images, robot pose, and semantic segmentations received by the agent [moma_llm].
- **T (Transition):** $T(s'|s, a)$ representing the probability of the state evolving from $s$ to $s'$ given action $a$ [moma_llm].
- **P (Observation model):** $P(o|s)$ representing the likelihood of receiving observation $o$ in state $s$ [moma_llm].
- **r (Reward):** Defined as $r(s, a)$, providing feedback on the action taken [moma_llm].

### 3.2 Approach: MoMa-LLM
To enable high-level reasoning, we construct a hierarchical scene graph $\mathcal{G}_{S}$ that abstracts the environment into room and object-level entities, grounded by a fine-grained navigational graph.

#### 3.2.1 Hierarchical 3D Scene Graph
The system builds a layered representation of the environment through dynamic mapping, topological graph generation, and semantic classification.

**Voronoi Graph Construction**
- **Computation:** We compute a Generalized Voronoi Diagram (GVD) from the inflated occupancy map. The GVD consists of points (nodes) that have equal clearance to the closest obstacles [moma_llm].
- **Navigation Utility:** The resulting nodes and edges form the navigational Voronoi graph $\mathcal{G_{V}}=(\mathcal{V},\mathcal{E})$. This graph allows the robot to navigate robustly by maximizing clearance from obstacles [moma_llm].

**Room Classification**
- **LLM Prompting:** The LLM is provided with a list of object categories contained within each room cluster (e.g., "armchairs, carpet, table-lamp" for room-0) [moma_llm].
- **Output Labels:** The LLM infers the semantic room type (e.g., classifying room-0 as a "living room" and room-1 as a "bedroom") [moma_llm].

#### 3.2.2 High-Level Action Space
**Actions (list explicitly)**
- `Maps(room, object)`: Navigate to a specific object or location.
- `go_to_and_open(room, object)`: Navigate to and interact with a container (e.g., fridge).
- `close(room, object)`: Close an opened container.
- `explore(room)`: Visit unexplored frontiers associated with a specific room.
- `done()`: Declare the task explicitly successful.

#### 3.2.3 Grounded High-Level Planning
The core contribution of MoMa-LLM lies in its ability to ground a Large Language Model (LLM) within a dynamically evolving scene graph [moma_llm].

**Scene Structure Encoding**
- The graph is serialized into a hierarchical list (Room -> Objects).
- Distances are binned into natural language adjectives ("near", "far") and object states are explicit ("closed fridge") [moma_llm].

**Partial Observability**
- **Frontiers:** Unknown space is explicitly represented as "Unexplored Area" (local) or "Leading Out" (global) nodes [moma_llm].
- **Replanning:** The prompt includes an "Analysis" and "Reasoning" step (Chain-of-Thought) before generating the next action command, with history dynamically realigned to the current map [moma_llm].

---

## 3.3 Experiments

### 3.3.1 Experimental Setup
- **Simulator:** iGibson (based on real-world scans) [igibson]
- **Robot (Sim):** Fetch mobile manipulator [moma_llm]
- **Robot (Real):** Toyota HSR [moma_llm]

### 3.3.2 Evaluation Metrics
- **Success Rate (SR):** Percentage of episodes where the target object is successfully found and `done()` is called.
- **SPL:** Success weighted by Path Length, measuring navigation efficiency.
- **AUC-E (Area Under Efficiency Curve):** A novel metric that plots success rates against varying time budgets, providing a robust measure of search efficiency independent of arbitrary cutoffs [moma_llm].

### 3.3.3 Results
**Simulation**
- **MoMa-LLM vs baselines:** MoMa-LLM achieved the highest Success Rate (97.7%), SPL (63.6), and AUC-E (87.2) [moma_llm].
- **Failure modes:** Primary failures were due to perception limitations or "infeasible actions" generated by the LLM when context was overwhelmed [moma_llm].

**Real-world Transfer**
- **Transfer capabilities:** The high-level reasoning transferred effectively to the real world (80% success rate) [moma_llm].
- **Latency and practical constraints:** Main constraints involved the computational latency of LLM queries and the reliance on specific detectors (like AR markers) to handle real-world perception noise [moma_llm].

---

## 4. Discussion

**Strengths**
- **Open-vocabulary reasoning:** Capable of handling novel room and object categories without retraining [moma_llm].
- **Structured reasoning with scene graphs:** Using scene graphs as a bridge allows the LLM to reason effectively about geometry and topology [moma_llm].
- **Robustness:** Demonstrated resilience to segmentation errors and real-world domain shifts [moma_llm].

**Limitations**
- **Perception dependency (garbage-in/garbage-out):** Heavily relies on ground-truth or high-quality semantics [moma_llm].
- **Latency (LLM calls, planning delays):** LLM queries dominate the runtime, and full graph re-computation scales poorly [moma_llm].
- **Cost blindness:** High-level planning decouples reasoning from low-level execution costs [moma_llm].

**Reproducibility**
- **Code availability:** The authors reference a project page [moma_project], but specific release details for the full pipeline are limited.
- **Missing details:** Real-world failure analysis is constrained by limited feedback modalities [moma_llm].

---

## 5. Conclusion

MoMa-LLM establishes a robust standard for semantic grounding in exploration by treating the Scene Graph as a dynamic, structured prompt. By tightly interleaving high-level semantic reasoning with object-centric low-level policies, this approach allows mobile manipulation robots to effectively explore, navigate, and interact with large, initially unknown environments. The empirical validation of this approach—particularly the efficiency gains over RL baselines—marks a definitive shift towards hybrid neuro-symbolic architectures in embodied AI.

Through extensive evaluation in both simulation and the real world, MoMa-LLM significantly outperforms conventional heuristics, reinforcement learning methods, and unstructured LLM baselines in terms of search efficiency and decision-making capabilities. Future work lies in cost-aware grounding and integrating VLM-based room classification.

---

## References
1. **[moma_llm]** Honerkamp, D., Schmalstieg, T., Welschehold, T., Abdo, N., Valada, A. "Language-Grounded Dynamic Scene Graphs for Interactive Object Search with Mobile Manipulation," arXiv:2403.08605, 2024.
2. **[hydra]** Hughes, N., Chang, Y., Carlone, L. "Hydra: A Real-time Spatial Perception System for 3D Scene Graph Construction and Optimization," RSS, 2022.
3. **[sayplan]** Rana, K., et al. "SayPlan: Grounding Large Language Models using 3D Scene Graphs for Scalable Robot Task Planning," CoRL, 2023.
4. **[esc]** Zhou, K., et al. "ESC: Exploration with Soft Commonsense Constraints for Zero-shot Object Navigation," ICML, 2023.
5. **[himos]** Schmalstieg, T., Honerkamp, D., Welschehold, T., Valada, A. "Learning Hierarchical Interactive Multi-Object Search for Mobile Manipulation," IROS, 2023.
6. **[conceptgraphs]** Gu, Q., et al. "ConceptGraphs: Open-Vocabulary 3D Scene Graphs for Perception and Planning," ICRA, 2024.
7. **[voronav]** Wu, P., et al. "VoroNav: Voronoi-based Zero-shot Object Navigation with Large Language Model," ICRA, 2024.
8. **[saycan]** Ahn, M., et al. "Do As I Can, Not As I Say: Grounding Language in Robotic Affordances," CoRL, 2022.
9. **[igibson]** Li, C., et al. "iGibson 2.0: Object-Centric Simulation for Robot Learning of Everyday Household Tasks," CoRL, 2021.
10. **[moma_project]** MoMa-LLM Project Page: https://moma-llm.cs.uni-freiburg.de/
