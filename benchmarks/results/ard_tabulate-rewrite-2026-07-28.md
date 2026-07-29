### `ard_tabulate()` engine rewrite benchmarks (#176)

 Run on 2026-07-28, R 4.6.1, cards 0.8.1.9000.

|scenario              |engine |min      |median   | itr/sec|mem_alloc | n_gc| speedup_vs_legacy|
|:---------------------|:------|:--------|:--------|-------:|:---------|----:|-----------------:|
|S1_tiny_overhead      |legacy |22.23ms  |28.43ms  |   34.30|96.11KB   |   12|              1.00|
|S1_tiny_overhead      |new    |14.89ms  |18.92ms  |   45.99|3.98MB    |   49|              1.50|
|S2_typical            |legacy |120.37ms |129ms    |    7.10|1001.98KB |    6|              1.00|
|S2_typical            |new    |47.29ms  |55.36ms  |   18.12|722.55KB  |   16|              2.33|
|S3_large_n            |legacy |270.39ms |337.9ms  |    3.16|292.82MB  |    3|              1.00|
|S3_large_n            |new    |84.75ms  |98.83ms  |    9.76|151.73MB  |    2|              3.42|
|S4_many_by_levels     |legacy |528.07ms |576.04ms |    1.71|35.72MB   |   10|              1.00|
|S4_many_by_levels     |new    |487.06ms |562.84ms |    1.74|28MB      |   31|              1.02|
|S5_sparse_strata      |legacy |189.39ms |194.99ms |    4.93|8.09MB    |    1|              1.00|
|S5_sparse_strata      |new    |72.22ms  |86.87ms  |   11.78|1.78MB    |    4|              2.24|
|S5b_hierarchical      |legacy |337.8ms  |363ms    |    2.76|10.97MB   |    3|              1.00|
|S5b_hierarchical      |new    |322.52ms |333.94ms |    2.81|6.93MB    |   10|              1.09|
|S6_many_variables     |legacy |2.53s    |2.6s     |    0.38|170.72MB  |   21|              1.00|
|S6_many_variables     |new    |1.08s    |1.1s     |    0.91|63.14MB   |   28|              2.37|
|S7_high_cardinality   |legacy |5.23s    |5.62s    |    0.18|199.05MB  |   79|              1.00|
|S7_high_cardinality   |new    |4.89s    |4.91s    |    0.19|151.38MB  |   59|              1.15|
|S8_stack_hierarchical |legacy |563.65ms |602.38ms |    1.69|17.04MB   |    6|              1.00|
|S8_stack_hierarchical |new    |440.89ms |453.69ms |    2.02|11.99MB   |    4|              1.33|
|S9_hierarchical_large |legacy |2.8s     |2.89s    |    0.32|153.15MB  |   35|              1.00|
|S9_hierarchical_large |new    |1.49s    |1.75s    |    0.55|75.21MB   |   20|              1.65|
