import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:to_memo/shared/constants.dart";
import "package:to_memo/shared/cubit/cubit.dart";
import "package:to_memo/shared/cubit/states.dart";
import "package:to_memo/screens/nav_bar_screens.dart";
class Home extends StatelessWidget{
  Home({super.key});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  bool _isLoading = true;
  @override
  Widget build(final BuildContext context)
  => BlocProvider<AppCubit>(
    create:(final BuildContext context)=>AppCubit()..openDB(),
    child:BlocConsumer<AppCubit,AppStates>(
      listener: (final BuildContext context,AppStates state){
        _isLoading=state is AppLoadingState;
      },
      builder:(final BuildContext context,AppStates state){
        AppCubit cubit = BlocProvider.of<AppCubit>(context);
        return Scaffold(
          key:_scaffoldKey,
          appBar:AppBar(
            title:Text(cubit.currentTab==0?"Home":"Favorites"),
            backgroundColor:Colors.orange,
            automaticallyImplyLeading: false,
          ),
          body:_isLoading?const Center(child:CircularProgressIndicator(color:Colors.amber)):const NavBarScreens(),
          bottomNavigationBar:BottomNavigationBar(
            elevation: 15,
            backgroundColor: Colors.orange,
            unselectedItemColor:Colors.white,
            selectedItemColor:Colors.black,
            items:const[
              BottomNavigationBarItem(
                icon:Icon(Icons.list),
                label:"Home"
              ),
              BottomNavigationBarItem(
                icon:Icon(Icons.favorite),
                label:"Favorites"
              ),
            ],
            onTap:(int i)=>cubit.changeTab(i),
            currentIndex:cubit.currentTab
          ),
          floatingActionButton:FloatingActionButton(
            backgroundColor: Colors.orange,
            onPressed:(){
              if(!cubit.isBottomSheetShown){
                cubit.showHideBottomSheet();
                _scaffoldKey.currentState!.showBottomSheet(
                  (final BuildContext context)=>Form(
                    key:formKey,
                    child: Padding(
                      padding:const EdgeInsets.all(12.0),
                      child:BlocBuilder<AppCubit, AppStates>(
                        builder: (final BuildContext context,AppStates state){
                          cubit=BlocProvider.of(context);
                          return Column(
                            mainAxisSize:MainAxisSize.min,
                            children:[
                              TextFormField(
                                controller:titleController,
                                style:const TextStyle(
                                  fontWeight:FontWeight.bold,
                                ),
                                cursorColor:Colors.black,
                                maxLength: 25,
                                decoration:InputDecoration(
                                  focusedBorder:const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black)
                                  ),
                                  hintText:"Title",
                                  hintStyle:const TextStyle(
                                    fontWeight:FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                  border:const OutlineInputBorder(),
                                  counterText:"${cubit.titleLength}/25"
                                ),
                                onTap: ()=>cubit.titleCounter(titleController.text.length),
                                onChanged: (String val){
                                  cubit.titleCounter(titleController.text.length);
                                },
                                validator:(String? title)=>title!.isEmpty?"Title must not be empty.":null
                              ),
                              const SizedBox(height:10),
                              TextField(
                                
                                controller:noteController,
                                maxLines:4,
                                cursorColor:Colors.black,
                                decoration:const InputDecoration(
                                  border:OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black)
                                  ),
                                ),
                              ),
                              const SizedBox(height:10),
                              ToggleButtons(
                                isSelected: cubit.selections,
                                selectedBorderColor: Colors.black,
                                borderRadius:BorderRadius.circular(100),
                                children:[
                                  for(int i=0;i<5;i++)
                                    Icon(Icons.circle,color:colors[i])
                                ],
                                onPressed:(int index)=>cubit.chooseColor(index)
                              )
                            ]
                          );
                        },
                      )
                    ),
                  ),
                  backgroundColor: Colors.orange[400],
                  elevation: 15
                ).closed.then((value) => cubit.showHideBottomSheet());
              }
              else if(formKey.currentState!.validate()){
                cubit.insertToDB(title: titleController.text,note:noteController.text);
                Navigator.pop(context);
                titleController.clear();
                noteController.clear();
                cubit.titleCounter(0);
              }
            },
            child:Icon(!cubit.isBottomSheetShown?Icons.edit:Icons.add)
          )
        );
      }
    )
  );
}