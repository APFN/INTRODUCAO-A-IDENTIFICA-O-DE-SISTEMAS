

function multi_analisaARX(u1,u2,y,u1_verif,u2_verif,y_verif,order,delay)


    [theta_ARX,res]=multi_identifyARX(u1,u2,y,order,delay)
    //sdev_ARX=stdev(res)
    disp(theta_ARX);
    sdev_ARX=stdev(res)
    y_ARX=multi_simulARX(u1_verif,u2_verif,theta_ARX,delay,0.01)
    /*
    y_ARX1=multi_simulARX(u1_verif,u2_verif,theta_ARX,1,0.01)
    y_ARX2=multi_simulARX(u1_verif,u2_verif,theta_ARX,2,0.01)
    y_ARX3=multi_simulARX(u1_verif,u2_verif,theta_ARX,3,0.01)   
    y_ARX4=multi_simulARX(u1_verif,u2_verif,theta_ARX,4,0.01)
    y_ARX5=multi_simulARX(u1_verif,u2_verif,theta_ARX,5,0.01)
    
    Y=[y_verif y_ARX y_ARX1 y_ARX2 y_ARX3 y_ARX4 y_ARX5] 
    */
    
    Y=[y_verif y_ARX]
    plot(Y)   

endfunction

function multi_analisaARMAX(u1,u2,y,u1_verif,u2_verif,y_verif,order,delay)


    [theta_ARMAX,res]=multi_identifyARMAX(u1,u2,y,order,delay)
    //sdev_ARX=stdev(res)
    disp(theta_ARMAX);
    sdev_ARX=stdev(res)
    y_ARMAX=multi_simulARMAX(u1_verif,u2_verif,theta_ARMAX,delay,0.01)
    /*
    y_ARMAX1=simulARMAX(u,theta_ARMAX,1,sdev_ARMAX)
    y_ARMAX2=simulARMAX(u,theta_ARMAX,2,sdev_ARMAX)
    y_ARMAX3=simulARMAX(u,theta_ARMAX,3,sdev_ARMAX)            
    y_ARMAX4=simulARMAX(u,theta_ARMAX,4,sdev_ARMAX)
    y_ARMAX5=simulARMAX(u,theta_ARMAX,5,sdev_ARMAX)
    Y=[y y_ARMAX y_ARMAX1 y_ARMAX2 y_ARMAX3 y_ARMAX4 y_ARMAX5] 
    */
    Y=[y_verif y_ARMAX]
    plot(Y);   

endfunction

//ballbeam
//analisaARMAX(u_verif1,u_verif2,y_verif,4,6);
multi_analisaARX(u1,u2,y,u1_verif,u2_verif,y_verif,1,6)

