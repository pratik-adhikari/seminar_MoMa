# Seminar Report: Language-Grounded Dynamic Scene Graphs for Interactive Object Search

**Student Name:** Pratik Adhikari  
**Date:** January 2026  
**Supervisor:** [Supervisor Name]  

## Abstract
To fully leverage mobile manipulation robots, agents must autonomously execute long-horizon tasks in large, unexplored environments. This paper addresses the challenge of **interactive object search**, where robots must navigate, explore, and manipulate objects (e.g., opening doors and drawers) to find targets in partially observable settings. We analyze MoMa-LLM, a novel approach that grounds Large Language Models (LLMs) within structured representations derived from open-vocabulary scene graphs, dynamically updated during exploration. By tightly interleaving these representations with an object-centric action space, the system achieves zero-shot, open-vocabulary reasoning. The paper introduces AUC-E (Area Under the Efficiency Curve) as a novel evaluation metric. Experiments demonstrate that MoMa-LLM achieves 97.7% success rate and 87.2 AUC-E in simulation, significantly outperforming baselines like HIMOS (93.7% SR) and ESC-Interactive (95.4% SR), while transferring effectively to real-world deployment with 80% success rate.

---

## 1. Introduction

Interactive embodied AI tasks in large, human-centered environments require robots to reason over long horizons and interact with a multitude of objects. In many real-world scenarios, these environments are *a priori* unknown or continuously rearranged, making autonomous operation significantly more difficult. Specifically, the task of **interactive object search** presents unique challenges: objects are not always openly visible—they may be stored inside receptacles like cabinets or drawers, or located behind closed doors. Consequently, an agent cannot rely on directional reasoning alone but must actively manipulate the environment to succeed [himos].

Recent advancements have demonstrated the potential of Large Language Models (LLMs) for generating high-level robotic plans [saycan]. However, existing methods such as SayCan or SayPlan are insufficient for interactive search in unexplored settings:

- **Assumption of Full Observability:** Many prior works focus on fully observed environments, such as tabletop manipulation or pre-explored scenes [sayplan].
- **Scalability and Hallucination:** In large, partially observable scenes, providing an LLM with raw observations or lists of objects increases the risk of generating impractical sequences. Simple prompting strategies have proven insufficient for complex reasoning.
- **Limited Scope:** Methods often restrict tasks to single rooms or rely on non-interactive navigation, failing to address multi-room exploration and physical interaction [himos].

To address these limitations, Honerkamp et al. propose **MoMa-LLM**, which grounds LLMs in dynamically built scene graphs. The approach constructs open-vocabulary scene graphs from dense maps and Voronoi graphs as the robot explores, extracting structured textual representations that enable efficient planning in partially observable environments.

---

## 2. Related Work

### 2.1 3D Scene Graphs
- **Hydra:** State-of-the-art real-time 3D Scene Graph construction, abstracting dense geometry into hierarchical topology [hydra]. Uses geometric constrictions for room separation.
- **ConceptGraphs:** Open-vocabulary 3D scene graphs built from foundation models for perception and planning [conceptgraphs].
- **VoroNav:** Voronoi-based navigation with LLM guidance for zero-shot object navigation [voronav].

### 2.2 LLMs for Planning
- **SayCan:** Grounds LLMs in robotic affordances, but assumes fully observed tabletop settings [saycan].
- **SayPlan:** Identifies subgraphs within large, *known* scene graphs for planning. Requires pre-explored environments [sayplan].
- **Key Gap:** Existing methods struggle with partially observed or unexplored environments.

### 2.3 Object Search
- **ESC (Exploration with Soft Commonsense):** Scores frontiers based on object co-occurrence probabilities [esc]. Extended to ESC-Interactive for this benchmark.
- **HIMOS:** Hierarchical reinforcement learning for interactive multi-object search, learning to compose navigation and manipulation skills [himos].
- **Key Gap:** Methods rely on pairwise scoring or directional reasoning, not joint scene-level planning with interaction.

---

## 3. Paper Summary

### 3.1 Problem Statement
The task is **Semantic Interactive Object Search**: find a specific object category (e.g., "Find a spoon") in an initially unexplored environment. Objects may be hidden inside receptacles (drawers, cabinets) or behind closed doors—the agent must actively manipulate the environment to succeed.

**POMDP Formulation**
The problem is formalized as a tuple $\mathcal{M} = (S, A, O, T, P, r)$:
- **S (States):** Complete world state—robot pose, map, object states (open/closed).
- **A (Actions):** Hybrid space with high-level primitives and low-level controllers.
- **O (Observations):** Posed RGB-D frames with semantic segmentation.
- **T (Transition):** $T(s'|s, a)$—probability of state evolution.
- **P (Observation model):** $P(o|s)$—observation likelihood.
- **r (Reward):** Minimize search cost (time/distance to find object).

**Success Condition:** The agent must observe the target object and explicitly execute `done()`.

### 3.2 Approach: MoMa-LLM

#### 3.2.1 Hierarchical 3D Scene Graph
The system constructs a layered representation with three components:

**1. Navigational Voronoi Graph ($\mathcal{G_V}$)**
- Computed from the Generalized Voronoi Diagram (GVD) of the inflated occupancy map using an Euclidean Signed Distance Field (ESDF).
- Nodes represent points with maximum clearance from obstacles—critical for mobile manipulators with large footprints.
- The largest connected component serves as the navigation backbone.

**2. Room Abstraction (Door-Based Separation)**
- Unlike Hydra's geometric constriction method, MoMa-LLM separates rooms using detected door locations.
- Models door positions with a Gaussian mixture: $\rho_{\mathcal{N}}(x,H)=\frac{1}{N_{D}}\sum_{i=1}^{N_{D}}K_{H}(x-x_{i})$.
- Edges in high-probability door regions are pruned, partitioning the graph into room components.

**3. Semantic Objects**
- Objects are assigned to rooms via *traversal distance* on the Voronoi graph (not Euclidean proximity)—prevents incorrect assignments through walls.
- LLM performs open-set room classification from object lists (e.g., "armchairs, carpet, table-lamp" → "living room").

#### 3.2.2 High-Level Action Space
| Action | Description |
|--------|-------------|
| `Maps(room, object)` | Navigate to a specific object |
| `go_to_and_open(room, object)` | Navigate to and open a container |
| `close(room, object)` | Close an opened container |
| `explore(room)` | Visit unexplored frontiers in a room |
| `done()` | Declare task complete |

#### 3.2.3 Grounded High-Level Planning

**Structured Knowledge Representation**
Rather than raw JSON, the system extracts a structured prompt with:
- **Distance Abstraction:** Metric distances binned to adjectives ("near", "far").
- **Object States:** Encoded into names ("closed fridge", "open drawer").
- **Frontiers:** Explicit "Unexplored Area" and "Leading Out" pseudo-objects.

**Dynamic History Realignment**
A key innovation: as the map evolves (e.g., "living room" reclassified as "kitchen" after seeing a fridge), previous actions are *re-mapped* to current room labels. This ensures the LLM always acts on a consistent world view.

**Chain-of-Thought Prompting**
The LLM is required to output:
1. **Analysis:** Where the target might be found.
2. **Reasoning:** Justification for the next action.
3. **Command:** The function call to execute.

---

## 3.3 Experiments

### 3.3.1 Experimental Setup
| Setting | Details |
|---------|---------|
| Simulator | iGibson (15 real-world scans) [igibson] |
| Robot (Sim) | Fetch mobile manipulator |
| Robot (Real) | Toyota HSR (RGB-D + LiDAR) |
| Real Environment | 4-room apartment, 54 object categories |

### 3.3.2 Evaluation Metrics
- **Success Rate (SR):** Found object + called `done()`.
- **SPL:** Success weighted by Path Length—penalizes inefficient paths.
- **AUC-E (Area Under Efficiency Curve):** *Novel metric* integrating SR across all time budgets. High AUC-E indicates finding objects *quickly*, not just eventually.

### 3.3.3 Results

**Simulation Results (Table I)**

| Method | SR (%) | SPL | AUC-E | Avg. Interactions |
|--------|--------|-----|-------|-------------------|
| **MoMa-LLM** | **97.7** | **63.6** | **87.2** | 3.9 |
| ESC-Interactive | 95.4 | 62.7 | 84.5 | 4.1 |
| HIMOS | 93.7 | 48.5 | 77.4 | 4.8 |
| Unstructured LLM | 86.3 | 59.4 | 77.6 | 3.6 |
| Random | 93.1 | 50.2 | 77.0 | 5.7 |

**Key Insights:**
- MoMa-LLM achieves the highest SR, SPL, and AUC-E among all methods.
- Unstructured LLM (raw JSON input) achieves only 86.3% SR with 0.41 invalid actions per episode vs. 0.19 for MoMa-LLM—demonstrating that structured prompting is essential.
- HIMOS achieves high SR (93.7%) but poor efficiency (SPL 48.5), indicating brute-force exploration.

**Real-World Results (Table III)**

| Method | SR | Distance (m) | Interactions |
|--------|----|--------------| -------------|
| **MoMa-LLM** | 80% (8/10) | **17.9** | **2.2** |
| ESC | 80% (8/10) | 33.9 | 3.5 |

MoMa-LLM traveled nearly half the distance and required fewer interactions, confirming that structured scene grounding enables more targeted behavior.

---

## 4. Discussion

### Strengths
- **Zero-shot Open-Vocabulary Reasoning:** Adapts to novel object/room categories without retraining.
- **Structured Grounding:** Scene graphs bridge perception and LLM reasoning, reducing hallucinations.
- **Real-World Transfer:** 80% success with sim-to-real transfer, despite different scene layouts.
- **Robustness to Segmentation Errors:** Policy functions even when room classification fails (27.6% accuracy in simulation).

### Limitations
- **Perception Dependency:** Requires ground-truth semantic masks, depth, localization, and handle detection. Sensor noise would degrade performance.
- **Open-Room Layouts:** Door-based separation struggles with open floor plans, leading to under-segmentation.
- **Computational Latency:** LLM queries dominate runtime. Full graph recomputation at each step is inefficient.
- **Sparse Feedback:** Only "success/failure" signals—cannot distinguish gripper slip from locked door.

### Future Directions
- **Vision-Language Models (VLMs):** Replace adjective-based encodings with dense visual representations.
- **Noisy Perception:** Construct graphs from raw sensor data without ground-truth assumptions.
- **Holistic Room Clustering:** Incorporate spatial and semantic details beyond door detection.
- **Enhanced Failure Feedback:** Visual analysis of object states and failure reasons.

### Reproducibility
- **Project Page:** https://moma-llm.cs.uni-freiburg.de/ [moma_project]
- **Code:** Referenced but full pipeline details limited.

---

## 5. Conclusion

MoMa-LLM establishes a new paradigm for semantic grounding in mobile manipulation by treating the scene graph as a dynamic, structured prompt. The framework demonstrates that:

1. **Structured representations outperform raw data** for LLM-based planning (97.7% vs. 86.3% SR).
2. **Interactive search** requires joint reasoning about navigation, exploration, and manipulation—not pairwise scoring.
3. **Dynamic scene graphs** with history realignment enable coherent long-horizon planning.

The empirical validation—particularly the 87.2 AUC-E and efficient real-world transfer—marks a significant step toward hybrid neuro-symbolic architectures for embodied AI.

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
