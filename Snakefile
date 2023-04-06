HASHES = [159562607389840577, 74457073119032237, 81038444938869519]

release_map = { 'release1': 'c_elegans.PRJNA13758.WS287.genomic.fa.gz',
                'release2': 'c_elegans.PRJEB28388.WS287.genomic.fa.gz',
                'release3': 'VC2010_2.0_Dec2022.fasta.gz' }

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


rule extents:
    input:
        expand("{hashval}.{release}.extents.fa",
               hashval=HASHES, release=release_map.keys()),
        "in_2_only.release2.extents.fa",
        "in_3_only.release3.extents.fa",


rule make_extreme_extents:
    input:
        sig="extreme-{hashval}.sig",
        genomes=release_map.values(),   # depend on all three, I guess
    output:
        "{hashval}.{release}.extents.fa",
    params:
        releasefile = lambda w: release_map[w.release],
    shell: """
        ./extract-max-extent-around-hashes.py -o {output} \
            {params.releasefile} {input.sig}
    """

rule make_excluded_extents_1:
    input:
        sig='in_2_only.sig',
        genome=release_map['release2'],
    output:
        "in_2_only.release2.extents.fa",
    shell: """
        ./extract-max-extent-around-hashes.py -o {output} \
            {input.genome} {input.sig}
    """


rule make_excluded_extents_2:
    input:
        sig='in_3_only.sig',
        genome=release_map['release3'],
    output:
        "in_3_only.release3.extents.fa",
    shell: """
        ./extract-max-extent-around-hashes.py -o {output} \
            {input.genome} {input.sig}
    """
