include ../Source/make_opts
SHELL = /bin/bash
LIBDIR = ../lib/
PROG   = check
LINKLIBS_ME =  -L../lib/ -ldhelas -lmodel
LINKLIBS_ALL =  -L../lib/ -lmatrix -ldhelas -lmodel
LIBS = $(LIBDIR)libdhelas.$(libext) $(LIBDIR)libmodel.$(libext)
PROCESS=  allmatrix.o
LIBRARY = libmatrix.a

# For python linking (require f2py part of numpy)
ifeq ($(origin MENUM),undefined)
  MENUM=2
endif

%$(MENUM)py.so: %/matrix.f
	$(F2PY) --f77exec=$(FC) $(LINKLIBS_ME) -c $^ -m $(patsubst %/matrix.f,%$(MENUM)py,$^)
	
all_matrix$(MENUM)py.so: $(LIBDIR)/$(LIBRARY) all_matrix.f
	$(F2PY) --f77exec=$(FC) $(LINKLIBS_ALL) -c all_matrix.f -m all_matrix$(MENUM)py

    
allmatrix$(MENUM)py.so: $(patsubst %/matrix.f,%$(MENUM)py.so,$(wildcard */matrix.f)) all_matrix$(MENUM)py.so
	for lib in $(patsubst %.so,%,$^); do \
		printf "try:\n    from $$lib import *\nexcept:\n    from .$$lib import *\n" >> allmatrix$(MENUM)py.py; \
	done

cpp: $(patsubst %.f,%.o,$(wildcard */matrix.f)) all_matrix.o
	g++ -O2 -ggdb -Wpadded -Wpacked -malign-double -mpreferred-stack-boundary=8 -fPIC -lgfortran all_matrix.f */matrix.f -L ../lib/ -ldhelas -lmodel -ffixed-line-length-0 -c;
test: $(LIBDIR)/$(LIBRARY) 
	g++ -O2 -ggdb -Wpadded -Wpacked -malign-double -mpreferred-stack-boundary=8 -fPIC -shared -lgfortran all_matrix.f */matrix.f -L ../lib/ -ldhelas -lmodel -lmatrix -ffixed-line-length-0 -o libSMEFTsim.so;
	
link_test: ../Source/DHELAS/*.o ../Source/MODEL/*.o all_matrix.o */matrix.o
	g++ test_pdg_order_renamed.cpp -ggdb -Wpadded -Wpacked -malign-double -mpreferred-stack-boundary=8 -lgfortran -L ./ -lgiga_renamed -ffixed-line-length-0;

$(LIBDIR)/$(LIBRARY): $(patsubst %.f,%.o,$(wildcard */matrix.f))  all_matrix.o
	$(call CREATELIB, $@, $^)  


cpp: $(LIBDIR)/$(LIBRARY)