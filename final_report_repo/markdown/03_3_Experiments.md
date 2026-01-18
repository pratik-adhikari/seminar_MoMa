### 3.3 Experiments

#### 3.3.1 Experimental Setup
The authors evaluated MoMa-LLM in both extensive simulation environments and a physical real-world deployment.
- **Simulation:** Experiments were conducted using the iGibson simulator, utilizing 15 interactive scenes based on real-world scans [1]. The agent controlled a Fetch robot to navigate and interact with these environments [2].
- **Real-World:** The approach was transferred to a Toyota HSR robot equipped with an RGB-D camera and LiDAR [3]. The testing environment was an apartment comprising four rooms (kitchen, living room, hallway, and bathroom) with 54 object categories [4].

#### 3.3.2 Evaluation Metrics
The evaluation employed standard metrics such as Success Rate (SR) and Success weighted by Path Length (SPL) [5]. However, the authors strongly emphasized a novel metric designed to address limitations in existing evaluation paradigms:
- **Area Under the Efficiency Curve (AUC-E):** The authors argue that standard metrics rely on arbitrary time budgets (e.g., a maximum number of steps), which fail to distinguish between agents that search thoroughly but slowly versus those that are fast but less comprehensive [6].
- **Rationale:** To resolve this, they calculate an efficiency curve plotting success rates against varying time budgets [7]. The AUC-E distills this curve into a single number, providing a robust measure of search efficiency that is independent of arbitrary cutoffs [8].

#### 3.3.3 Baselines
MoMa-LLM was compared against a diverse set of baselines ranging from heuristics to learning-based methods:
- **Random & Greedy:** Heuristic baselines that select actions uniformly or based on distance [9].
- **ESC-Interactive:** An extension of the "Exploration with Soft Commonsense Constraints" approach, which scores frontiers based on object co-occurrences [10].
- **HIMOS:** A hierarchical reinforcement learning approach adapted for interactive search [11].
- **Unstructured LLM:** A baseline using the same LLM but provided with a raw JSON scene graph rather than the structured, language-grounded representation proposed by the authors [12].

#### 3.3.4 Results
**Simulation Results (Table I)**
MoMa-LLM demonstrated superior performance across all metrics, proving to be the most efficient and effective method.
- **Top Performance:** MoMa-LLM achieved the highest Success Rate (97.7%), SPL (63.6), and AUC-E (87.2) [13].
- **Comparison:** It significantly outperformed the Unstructured LLM (SR 86.3%, AUC-E 77.6%), highlighting that simply feeding a scene graph to an LLM is insufficient without structured grounding [14]. The Unstructured LLM also generated significantly more invalid actions (0.41 vs 0.19) [15].
- **Efficiency:** While HIMOS achieved a high success rate (93.7%), it lacked efficiency (SPL 48.5) compared to MoMa-LLM [16]. ESC-Interactive performed well but struggled to optimize long-horizon sequences compared to the planning capabilities of the LLM [17].

**Real-World Results (Table III)**
The system successfully transferred to the physical robot with consistent results.
- **Success:** Both MoMa-LLM and the strongest baseline, ESC, achieved an 80% success rate (8/10 episodes) [18].
- **Efficiency Gains:** MoMa-LLM was drastically more efficient, traveling nearly half the distance of ESC (17.9m vs. 33.9m) and requiring fewer object interactions (2.2 vs. 3.5) to locate the target [19].
- **Conclusion:** The results confirm that MoMa-LLM's structured knowledge representation enables more target-driven behavior, reducing unnecessary exploration and interaction compared to co-occurrence or heuristic methods [20].
