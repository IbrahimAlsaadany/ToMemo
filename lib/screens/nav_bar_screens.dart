import "package:flutter/material.dart";
import "package:to_memo/shared/components.dart";
import "package:to_memo/shared/cubit/cubit.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:to_memo/shared/cubit/states.dart";
class NavBarScreens extends StatelessWidget{
  const NavBarScreens({super.key});
  @override
  BlocBuilder<AppCubit,AppStates> build(final BuildContext context){
    AppCubit cubit = BlocProvider.of<AppCubit>(context);
    return BlocBuilder<AppCubit, AppStates>(
      builder: (final BuildContext context,AppStates state){
        return cubit.isEmptyList()?
        Center(
          child:Column(
            mainAxisAlignment:MainAxisAlignment.center,
            children:[
              Icon(cubit.currentTab==0?Icons.notes:Icons.favorite,size:150,color:Colors.amber[200]),
              Text(
                cubit.currentTab==0? "There's no notes. Add some.":"No favorites.",
                style:TextStyle(
                  fontSize:20,
                  fontWeight:FontWeight.bold,
                  letterSpacing:1,
                  color:Colors.amber[200]
                )
              )
            ]
          )
        ):
        ListView.builder(
          itemBuilder:(final BuildContext context, int index) =>buildNoteItem(
            context,
            id:cubit.whichClicked<int>("id", index),
            title:cubit.whichClicked<String>("title", index),
            note:cubit.whichClicked<String>("note",index),
            status:cubit.whichClicked<String>("status",index),
            color: cubit.whichClicked<int>("color", index)
          ),
          itemCount:(cubit.currentTab==0?cubit.notes:cubit.favorites).length,
          padding:const EdgeInsets.only(bottom: 50),
        );
      },
    );
  }
}