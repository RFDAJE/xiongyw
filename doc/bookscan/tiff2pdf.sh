#!/bin/bash

#!/bin/bash
for f in *.tif; do
    tiff2pdf -o ${f%tif}pdf $f
done

