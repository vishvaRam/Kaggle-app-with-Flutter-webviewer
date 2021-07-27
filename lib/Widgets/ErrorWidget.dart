import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';


class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 250.h,
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 50.h, horizontal: 20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "Assets/happy.svg",
                  height: 170.h,
                ),
                SizedBox(
                  height: 30.h,
                ),
                Text(
                  "Add to Bookmark",
                  style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 15.h,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: "Use the bookmark icon ",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.normal)),
                      WidgetSpan(
                        style: TextStyle(fontSize: 22.sp),
                        child: Icon(
                          Icons.bookmark_border,
                          color: Color(0xff536DFE),
                        ),
                      ),
                      TextSpan(
                          text: " to save.",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ))),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      child: Text(
                        "Explore",
                        style: TextStyle(
                            fontSize: 22.sp,
                            color: Colors.white,
                            letterSpacing: 1.5.sp),
                      ),
                    ))
              ],
            ),
          ),
        ));
  }
}


class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 250.h,
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 50.h, horizontal: 20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "Assets/noInternet.svg",
                  height: 170.h,
                ),
                SizedBox(
                  height: 30.h,
                ),
                Text("Please make sure you have internet connection!",style: TextStyle(
                  fontSize: 18.sp
                ),)
              ],
            ),
          ),
        ));
  }
}
