            .text

start:      li    t0, 1
            li    t1, 1

fibonacci:  mv    a0, t1
            add   t1, t0, t1
            mv    t0, a0
            addi  t3, t3, 1
            j   fibonacci
