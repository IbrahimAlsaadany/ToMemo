import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:to_memo/shared/components.dart";
import "package:to_memo/shared/constants.dart";
import "package:to_memo/shared/cubit/cubit.dart";
import "package:to_memo/shared/cubit/states.dart";
class OpenedNoteScreen extends StatelessWidget{
  int id,color;
  String status;
  AppCubit prevCubit;
  OpenedNoteScreen({
    super.key,
    required this.id,
    required this.color,
    required String title,
    required String note,
    required this.status,
    required this.prevCubit
  }){
    _titleController.text=title;
    _noteController.text=note;
  }
  final TextEditingController _titleController=TextEditingController();
  final TextEditingController _noteController=TextEditingController();
  @override
  BlocProvider<AppCubit> build(final BuildContext context)
  => BlocProvider(
    create: (context) => AppCubit()..openDB()..titleLength=_titleController.text.length,
    child: BlocBuilder<AppCubit, AppStates>(
      builder: (final BuildContext context,AppStates state) {
        final AppCubit cubit = BlocProvider.of<AppCubit>(context);
        return Scaffold(
        appBar:AppBar(
          title:Text(_titleController.text),
          backgroundColor: Colors.orange,
          actions:[
            DropdownButton(
              onChanged:cubit.readOnly?null:(dynamic value)=>cubit.changeColor(color=value),
              iconEnabledColor: Colors.white,
              underline:const Divider(color: Colors.white),
              iconDisabledColor: Colors.amber[200],
              value:color,
              onTap: (){},
              borderRadius: BorderRadius.circular(10),
              alignment: Alignment.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 4
              ),
              items:[
                for(int i=0;i<5;i++)
                  buildDropDownItem(color: i, readOnly: cubit.readOnly)
              ]
            ),
            IconButton(
              icon:Icon(cubit.readOnly?Icons.edit_document:Icons.save),
              onPressed:()=>cubit.editSave(
                id:id,
                color:color,
                title:_titleController.text,
                note:_noteController.text,
                status:status,
                prevCubit:prevCubit
              )
            )
          ]
        ),
        backgroundColor: colors[color],
        body:Column(
          children: [
            TextFormField(
              controller:_titleController,
              readOnly:cubit.readOnly,
              style:const TextStyle(
                fontWeight:FontWeight.bold,
                fontSize:30
              ),
              cursorColor:Colors.black,
              maxLength: 25,
              decoration:InputDecoration(
                hintText:"Title",
                focusedBorder:const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)
                ),
                hintStyle:const TextStyle(
                  fontWeight:FontWeight.bold,
                  letterSpacing: 1,
                ),
                contentPadding:const EdgeInsets.all(8.0),
                counterText:"${cubit.titleLength}/25"
              ),
              onChanged: (String val){
                cubit.titleCounter(_titleController.text.length);
              },
              validator:(String? title)=>title!.isEmpty?"Title Must not be empty":null
            ),
            Expanded(
              child: TextField(
                maxLines:null,
                autofocus:true,
                controller:_noteController,
                readOnly:cubit.readOnly,
                style:const TextStyle(fontSize:20),
                cursorColor:Colors.black,
                decoration:const InputDecoration(
                  contentPadding:EdgeInsets.all(8),
                  border:InputBorder.none,
                ),
              ),
            )
          ],
        )  
      );
      },
    ),
  );
}