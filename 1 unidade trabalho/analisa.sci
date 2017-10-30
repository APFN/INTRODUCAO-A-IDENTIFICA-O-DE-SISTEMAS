
function analisaARX(u_verif,y_verif,u,y,order,delay)


    [theta_ARX,res]=identifyARX(u,y,order,delay)
    //sdev_ARX=stdev(res)
    disp(theta_ARX);
    sdev_ARX=stdev(res)
    y_ARX=simulARX(u_verif,theta_ARX,delay,0)
    /*
    y_ARX1=simulARX(u,theta_ARX,1,sdev_ARX)
    y_ARX2=simulARX(u,theta_ARX,2,sdev_ARX)
    y_ARX3=simulARX(u,theta_ARX,3,sdev_ARX)            
    y_ARX4=simulARX(u,theta_ARX,4,sdev_ARX)
    y_ARX5=simulARX(u,theta_ARX,5,sdev_ARX)
    
    Y=[y y_ARX y_ARX1 y_ARX2 y_ARX3 y_ARX4 y_ARX5] 
    */
    Y=[y_verif y_ARX]
    plot(Y)   

endfunction

function analisaARMAX(u,y,order,delay)
        
    [theta_ARMAX,res]=identifyARMAX(u,y,order,delay);     
    //sdev_ARMAX=stdev(res)
    sdev_ARMAX=0
    y_ARMAX=simulARMAX(u,theta_ARMAX,delay,sdev_ARMAX)
    /*
    y_ARMAX1=simulARMAX(u,theta_ARMAX,1,sdev_ARMAX)
    y_ARMAX2=simulARMAX(u,theta_ARMAX,2,sdev_ARMAX)
    y_ARMAX3=simulARMAX(u,theta_ARMAX,3,sdev_ARMAX)            
    y_ARMAX4=simulARMAX(u,theta_ARMAX,4,sdev_ARMAX)
    y_ARMAX5=simulARMAX(u,theta_ARMAX,5,sdev_ARMAX)
    Y=[y y_ARMAX y_ARMAX1 y_ARMAX2 y_ARMAX3 y_ARMAX4 y_ARMAX5] 
    */
    Y=[y y_ARMAX]
    plot(Y);   

endfunction

//ballbeam
//analisaARMAX(u_verif1,u_verif2,y_verif,4,6);
analisaARX(u_verif,y_verif,u,y,2,2);
