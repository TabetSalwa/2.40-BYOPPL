
all:
	dune build

clean:
	dune clean

doc:
	dune build @doc


.PHONY: clean
