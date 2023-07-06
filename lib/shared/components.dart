import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:to_memo/shared/constants.dart";
import "package:to_memo/shared/cubit/cubit.dart";
import "package:to_memo/screens/opened_note.dart";
GestureDetector buildNoteItem(
    final BuildContext context,
  {
    required final int id,
    required int color,
    required final String title,
    required final String note,
    required final String status,
  }){
  AppCubit cubit = BlocProvider.of<AppCubit>(context);
  ScaffoldMessengerState snack=ScaffoldMessenger.of(context);
  return GestureDetector(
    onTap:()=>Navigator.push(
      context,
      MaterialPageRoute(
        builder:(final BuildContext context)
        =>OpenedNoteScreen(
          id:id,
          color:color,
          title:title,
          note:note,
          status:status,
          prevCubit: cubit,
        )
      )
    ),
    child: Dismissible(
      key:UniqueKey(),
      background:Container(
        color:Colors.red,
        child:const Icon(Icons.delete,color:Colors.white)
      ),
      
      onDismissed: (DismissDirection direction){
        cubit.removeData(id);
        snack.hideCurrentSnackBar();
        snack.showSnackBar(SnackBar(
          content:const Text("Are you sure to delete note ?"),
          showCloseIcon:true,
          action:SnackBarAction(
            label:"Undo",
            onPressed:()=>cubit.undoRemove(),
          )
        )).closed.then((SnackBarClosedReason reason){
          switch(reason){
            case SnackBarClosedReason.action:
              break;
            default:
              cubit.deleteFromDB(id);
          }
        });
      },
      child:Container(
        decoration:BoxDecoration(
          color: colors[color],
          border:const Border(bottom: BorderSide(color:Colors.grey))
        ),
        height:100,
        width:double.infinity,
        child:Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Text(
                      title,
                      textAlign: TextAlign.start,
                      style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)
                    ),
                    Text(
                      note,
                      maxLines: 2,
                      style:TextStyle(
                        color:Colors.grey[700]
                      ),
                      overflow:TextOverflow.ellipsis
                    ),
                  ]
                ),
              ),
              IconButton(
                padding:EdgeInsets.zero,
                icon:Stack(
                  children: [
                    Icon(
                      status=="normal"? null:Icons.favorite,
                      color: Colors.red[700],
                      size:40
                    ),
                    const Icon(
                      Icons.favorite_border_outlined,
                      color:Colors.black,
                      size:40
                    )
                  ],
                ),
                onPressed:(){
                  cubit.addRemoveFavoriteDB(id:id,status:status);
                }
              ),
            ],
          ),
        )
      ),
    ),
  );
}
DropdownMenuItem buildDropDownItem({
  required final  int color,
  required final bool readOnly,
})
=> DropdownMenuItem(
  value:color,
  child:   Stack(
    children:[
      Text(
        colorNames[color],
        style:TextStyle(
          foreground:Paint()
          ..style=PaintingStyle.stroke
          ..strokeWidth=3
          ..color=Colors.black
        )
      ),
      Text(
        colorNames[color],
        style:TextStyle(
          color:readOnly?Colors.amber[200]:colors[color],
        )
      )
    ]
  ),
);