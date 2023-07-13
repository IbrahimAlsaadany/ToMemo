import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:to_memo/shared/components.dart";
import "package:to_memo/shared/constants.dart";
import "package:to_memo/shared/cubit/cubit.dart";
import "package:to_memo/shared/cubit/states.dart";
class OpenedNoteScreen extends StatelessWidget{
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int id,color;
  String status;
  AppCubit cubit;
  OpenedNoteScreen({
    super.key,
    required this.id,
    required this.color,
    required final String title,
    required final String note,
    required this.status,
    required this.cubit
  }){
    _titleController.text=title;
    _noteController.text=note;
    cubit.readOnly=true;
  }
  final TextEditingController _titleController=TextEditingController();
  final TextEditingController _noteController=TextEditingController();
  @override
  BlocBuilder<AppCubit,AppStates> build(final BuildContext context)
  => BlocBuilder<AppCubit, AppStates>(
    bloc:cubit,
    builder: (final BuildContext context,AppStates state) {
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
            onPressed:(){
              if(_formKey.currentState!.validate())
                cubit.editSave(
                  id:id,
                  color:color,
                  title:_titleController.text,
                  note:_noteController.text,
                  status:status,
                );
            }
          )
        ]
      ),
      backgroundColor: colors[color],
      body:Column(
        children: [
          Form(
            key:_formKey,
            child: TextFormField(
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
              validator:(String? title)=>title!.isEmpty?"Title must not be empty.":null
            ),
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
  );
}