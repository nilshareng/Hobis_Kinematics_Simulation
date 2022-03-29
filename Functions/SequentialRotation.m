function [Mat] = SequentialRotation(Angles,Seq)
% Automatic 1, 2 or 3 rotation matrix according to X, Y and/or Z axes

switch Seq
    case 'xyz'
        Mat = RotationX(Angles(1))*RotationY(Angles(2))*RotationZ(Angles(3));
    case 'xzy'
        Mat = RotationX(Angles(1))*RotationZ(Angles(3))*RotationY(Angles(2));
    case 'yxz'
        Mat = RotationY(Angles(2))*RotationX(Angles(1))*RotationZ(Angles(3));
    case 'yzx'
        Mat = RotationY(Angles(2))*RotationZ(Angles(3))*RotationX(Angles(1));
    case 'zxy'
        Mat = RotationZ(Angles(3))*RotationX(Angles(1))*RotationY(Angles(2));
    case 'zyx'
        Mat = RotationZ(Angles(3))*RotationY(Angles(2))*RotationX(Angles(1));
    
    case 'xy'
        Mat = RotationX(Angles(1))*RotationY(Angles(2));
    case 'xz'
        Mat = RotationX(Angles(1))*RotationZ(Angles(3));    
    case 'yx'
        Mat = RotationY(Angles(2))*RotationX(Angles(1));
    case 'yz'
        Mat = RotationY(Angles(2))*RotationZ(Angles(3));
    case 'zx'
        Mat = RotationZ(Angles(3))*RotationX(Angles(1));
    case 'zy'
        Mat = RotationZ(Angles(3))*RotationY(Angles(2));
        
    case 'x'
        Mat = RotationX(Angles(1));
    case 'y'
        Mat = RotationY(Angles(2));    
    case 'z'
        Mat = RotationZ(Angles(3));
end

