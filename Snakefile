rule all:
    input:
        "VC2010_2.0_Dec2022.fasta.gz.sig",
        "c_elegans.PRJEB28388.WS287.genomic.fa.gz.sig",
        "c_elegans.PRJNA13758.WS287.genomic.fa.gz.sig"


rule make_sig:
    input:
        "{filename}.gz"
    output:
        "{filename}.gz.sig",
    shell: """
        sourmash sketch dna -p k=15,k=21,k=31,k=51,scaled=100,abund {input} \
           -o {output}
    """
