#!/bin/bash

# created(bruin, 2017-02-08)

# this is a central place to keep all pacemaker resource constraints, including
# coloation and oder constraints.
#
# these constrains can be applied any times, even if some of the related resources
# are not defined, or the constraints are already defined. pcs just returns error
# and we safely ignore errors...this is a kind of idempotency we expect.




