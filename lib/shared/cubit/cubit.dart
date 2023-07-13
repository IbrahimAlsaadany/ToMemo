import "package:flutter_bloc/flutter_bloc.dart";
import "package:sqflite/sqflite.dart";
import "package:to_memo/shared/cubit/states.dart";
class AppCubit extends Cubit<AppStates>{
  AppCubit():super(AppInitialState());
  int currentTab=0,titleLength=0,_colorIndex=0;
  bool isBottomSheetShown = false,readOnly=true;
  late List<Map<String,dynamic>> notes,favorites;
  late int _favoritesUndoIndex,_notesUndoIndex;
  late Map<String,dynamic> _undoData;
  late final Database _db;
  final List<bool> selections=List.filled(5, false)..first=true;
  void changeTab(int i){
    currentTab=i;
    emit(AppScreenChangeState());
  }
  void showHideBottomSheet(){
    isBottomSheetShown=!isBottomSheetShown;
    emit(AppBottomSheetChangeState());
  }
  void openDB(){
    emit(AppLoadingState());
    openDatabase(
      'to_memo.db',
      version:1,
      onCreate:(Database db,int version){
        emit(AppLoadingState());
        db.execute("CREATE TABLE notes(id INTEGER,color INTEGER,title TEXT,note TEXT,status TEXT)");
      },
      onOpen: (Database db){
        emit(AppLoadingState());
        _db=db;
        _db.rawQuery("SELECT * FROM notes")
        .then((List<Map> data){
          notes=<Map<String,dynamic>>[for (Map _ in data) Map<String,dynamic>.from(_)];
        });
        _db.rawQuery("SELECT * FROM notes WHERE status='favorite'")
        .then((List<Map<String,dynamic>> data){
          favorites=<Map<String,dynamic>>[for (Map _ in data) Map<String,dynamic>.from(_)];
          emit(AppGotDataFromDBState());
        });
      }
    );
  }
  void insertToDB({
    required final String title,
    required final String note,
    })async{
      for(int i=1;i<5;i++) selections[i]=false;
      selections[0]=true;
      notes.add({"title":title,"note":note,"color":_colorIndex,"status":"normal","id":_getLastID()+1});
      await _db.rawInsert("INSERT INTO notes(id,color,title,note,status) values(?,?,?,?,?)",[_getLastID(),_colorIndex,title,note,'normal']);
      emit(AppInsertToDBState());
  }
  void addRemoveFavoriteDB({required final int id,required final String status})async{
    int index = notes.indexWhere((e)=>e["id"]==id);
    if(status=="normal")
      favorites.add(notes[index]..update("status",(value)=>"favorite"));
    else if(currentTab==0){
      notes[index]=notes[index]..update('status', (value) => 'normal');
      favorites.removeWhere((Map element)=>element["id"]==id);
    }
    else
      notes[index]=favorites.removeAt(favorites.indexWhere((Map<String,dynamic> e)=>id==e['id']))..update('status', (value) => 'normal');
    emit(AppNoteItemChangeState());
    await _db.rawUpdate("UPDATE notes SET status = ? where id=?",[status=="normal"?"favorite":"normal",id]);
  }
  void deleteFromDB(int id)async=>await _db.rawDelete("DELETE FROM notes WHERE id=?",[id]);
  void removeData(int id){
    _favoritesUndoIndex=favorites.indexWhere((Map<String,dynamic> e)=>e["id"]==id);
    _notesUndoIndex=notes.indexWhere((Map<String,dynamic> e)=>e["id"]==id);
    _undoData = notes.removeAt(_notesUndoIndex);
    if(_favoritesUndoIndex!=-1) favorites.removeAt(_favoritesUndoIndex);
    emit(AppNoteItemChangeState());
  }
  void undoRemove(){
    notes.insert(_notesUndoIndex, _undoData);
    if(_favoritesUndoIndex!=-1) favorites.insert(_favoritesUndoIndex,_undoData);
    emit(AppNoteItemChangeState());
  }
  bool isEmptyList()=>notes.isEmpty||currentTab==1&&favorites.isEmpty;
  T whichClicked<T>(String inp,int index)
  => currentTab==0?notes[index][inp]:favorites[index][inp];
  int _getLastID()=>notes.isNotEmpty?notes.last["id"]:-1;
  void titleCounter(final int l ){
    titleLength=l;
    emit(AppTypingTitleState());
  }
  void editSave({
    required final int id,
    required final int color,
    required final String title,
    required final String note,
    required final String status,
  })async{
    readOnly=!readOnly;
    if(readOnly){
      int favoriteIndex = favorites.indexWhere((Map<String,dynamic> e) => e["id"]==id);
      notes[notes.indexWhere((Map<String,dynamic> e) => e["id"]==id)]
        ={"id":id,"title":title,"note":note,"status":status,"color":color};
      if(favoriteIndex!=-1)
        favorites[favoriteIndex]={"id":id,"title":title,"note":note,"status":status,"color":color};
      await _db.rawUpdate("UPDATE notes SET title=?,note=?,color=? where id=?",[title,note,color,id]);
    }
    emit(AppChangeOpenedNoteState());
  }
  void changeColor(final int _)=>emit(AppChangeOpenedNoteState());
  void chooseColor(final int index){
    _colorIndex=index;
    for(int i=0;i<5;i++) selections[i]=i==index;
    emit(AppBottomSheetChangeState());
  }
}