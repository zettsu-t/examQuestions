# 麻布中学校 2008年 入試問題 算数 問4
makelist=$(foreach v,$1+ $1*,$(addprefix $(v),$2))
LIST1TO4:=$(call makelist,1,$(call makelist,2,$(call makelist,3,4)))
LIST1TO5:=$(call makelist,1,$(call makelist,2,$(call makelist,3,$(call makelist,4,5))))
LIST2TO6:=$(call makelist,2,$(call makelist,3,$(call makelist,4,$(call makelist,5,6))))
Q2EXPRS:=$(foreach v1,$(LIST1TO5),$(foreach v2,$(LIST2TO6),$(addprefix $(v1)==,$(v2))))
q1=$(foreach v,$1,$(shell echo $(v)|bc) = $(v)::)
q2=$(filter %=1=::,$(foreach v,$1,$(v)=$(shell echo $(v)|bc)=::))
.PHONY: all force
all: force
	@echo $(call q1,$(LIST1TO4)) | sed -e 's/::/\n/g' | sed -e 's/^[ ]*//' | sort -n
	@echo $(call q2,$(Q2EXPRS)) | sed -e 's/::/\n/g' | sed -e 's/^[ ]*//' | sed -e 's/=1=//g'
