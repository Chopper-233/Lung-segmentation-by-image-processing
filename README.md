# Lung-segmentation-by-image-processing 
Lung segmentation on Chest-Xray dataset by traditional image processing method

Five steps for our algorithm

1.Canny edge detection and otsu for segmentation and background removal

2.close operation to remove edge disconnect

3.extract lung parts by setting up connect regions' size

4.remove empty small holes in lung parts

5.calculate image coefficience  
###Figure1.Algorithm  
！[image]https://github.com/Chopper-233/Lung-segmentation-by-image-processing/blob/main/algorithm.png  
###Figure2.Original CXR&Canny edge detection&otsu seg  
！[image]https://github.com/Chopper-233/Lung-segmentation-by-image-processing/blob/main/seg1.png  
###Figure3.CXR ribs filled with close operation  
！[image]https://github.com/Chopper-233/Lung-segmentation-by-image-processing/blob/main/seg2.png  
###Figure4.Lung connection parts extraction by sequenzing connection parts  
！[image]https://github.com/Chopper-233/Lung-segmentation-by-image-processing/blob/main/seg3.png  
###Figure5.Final result & Mask  
！[image]https://github.com/Chopper-233/Lung-segmentation-by-image-processing/blob/main/seg4.png
