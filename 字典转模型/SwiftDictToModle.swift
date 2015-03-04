//
//  SwiftDictToModle.swift
//  字典转模型
//
//  Created by cctao on 15/3/4.
//  Copyright (c) 2015年 cctao. All rights reserved.
//

import Foundation

@objc protocol DictModelProtocol{
    
    static func customeClassMapping()->[String:String]?
}


class SwiftDictToModle {
    /**
    字典转模型
    
    :param: dict 字典的描述
    :param: cls  类模型
    
    :returns: 转换好的模型
    */
    func objectWithDictionary(dict:NSDictionary,cls:AnyClass)->AnyObject?{
        
        //获取模型类的字典
        let dictInfo = fullModleInfo(cls)
        //实例化对象
        var obj:AnyObject = cls.alloc()
        //遍历模型字典，有什么属性就设置什么属性
        //k 应该和dict 中的key 是一致的
        for (k,v) in dictInfo{
            //取出字典中的内容
            if let value:AnyObject? = dict[k]{
                //判断是否自定义类型
                if v.isEmpty && !(value === NSNull()){
                    //不是自定义类型直接kvc 赋值
                    obj.setValue(value, forKey: k)
                }else {
                    
                    let type = "\(value!.classForCoder)"
                    if type == "NSDictionary"{
                        //是字典就可以递归使用该函数
                        //value 是字典--》将value 的字典转化成info的对象
                        if let subObj:AnyObject? = objectWithDictionary(value as! NSDictionary, cls: NSClassFromString(v))
                        {
                          obj.setValue(subObj, forKey: k)
                        }
                    
                    
                }else if type == "NSArray"{
                        if let subObj:AnyObject = objectWithArray(value as! NSArray, cls: cls){
                            obj.setValue(subObj, forKey: k)
                        }
                }
            
          }//let value:AnyObject? = dict[k] else end
        }//let value:AnyObject? = dict[k] end
    }// for (k,v) in dictInfo end
    return obj
}
    /**
    将数组转化成模型字典
    
    :param: array 数组描述
    :param: cls   模型类
    
    :returns: 模型数组
    */
func objectWithArray(array:NSArray,cls:AnyClass)->[AnyObject]?{
        var result = [AnyObject]()
        
        for value in array {
            let type  = "\(value.classForCoder)"
            if type == "NSDictionary"{
                if let subObj:AnyObject = objectWithDictionary(value as!NSDictionary, cls: cls)
                {
                    result.append(subObj)
                }
            }else if type == "NSArray" {
                if let subObj:AnyObject = objectWithArray(value as! NSArray, cls: cls){
                    result.append(subObj)
                }
            }
        
        
    }//for value in array end
    return result
}
    
    /**
    获取类型的完整信息
    
    :param: cls 给定类
    
    :returns: 返回类的完整信息
    */
    func fullModleInfo(cls:AnyClass)->[String:String]{
        //循环查找傅雷
        //1.记录参数
        //2.循环中不会处理NSObject
        var currentClass :AnyClass = cls
        var dictInfo = [String:String]()
        while let parent:AnyClass = currentClass.superclass(){
            
            dictInfo.merge(modleInfo(currentClass))
            currentClass = parent
        }
        
        
        
        return dictInfo
        
    }
    

    /**
    获取给定类的信息
    
    :param: cls 给定的类
    
    :returns: 给定类的成员变量的信息
    */
    
    func modleInfo(cls:AnyClass)->[String:String]{
        
        var mapping:[String:String]?
        //判断是否遵守协议
        if cls.respondsToSelector("customeClassMapping"){
            println("实现了协议")
            mapping = cls.customeClassMapping()
            
        }
        var count:UInt32 = 0
        let ivars = class_copyIvarList(cls, &count)
        
        println("有\(count)个属性")
        
        
        var dictInfo = [String :String]()
        
        for i in 0..<count{
           let ivar = ivars[Int(i)]
        //获取ivar的name
            let cname = ivar_getName(ivar)
            //将c语言字符串转化成swift的字符串
            let name  = String.fromCString(cname)!
            var type = ""
            if mapping?[name] != nil{
                type = mapping![name]!
            }
            dictInfo[name]! = type
            
            
        }
        
        return dictInfo
    }
    
    
    
    
}

extension Dictionary{
    
    
    /**
    将给定的字典合并到当前的字典中
    mutating 表示函数操作的字典是可变类型的
    泛型，封装一些函数或者方法更加有弹性
    任何俩个[k,v]类型匹配字典都都可以进行合并操作
    :param: dict <#dict description#>
    */
    
    mutating func merge<K,V>(dict:[K:V]){
        for (k,v) in dict{
            //字典的分类方法中，如果要使用updateValue，需要明确的指定类型
            self.updateValue(v as!Value, forKey: k as! Key)
        }
    }
    
    
    
}

























