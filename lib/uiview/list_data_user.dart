import 'package:client_server_flutter/model/model_data_user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PageListDataView extends StatefulWidget {
  const PageListDataView({super.key});

  @override
  State<PageListDataView> createState() => _PageListDataViewState();
}

class _PageListDataViewState extends State<PageListDataView> {

  late Future<List<DataUser>?> futureUser;

  Future<List<DataUser>?> getDataUser() async{
    print('getDataUser called ...');
    try{

      final response = await http.get(Uri.parse('https://reqres.in/api/users?page=2'),
        headers: {
          'x-api-key': 'reqres-free-v1',
        },
      );

      print('Response body : ${response.body}');

      if(response.statusCode == 200){
        return modelListDataFromJson(response.body).data;
      }else{
        throw Exception('Failed to load data : ${response.statusCode}');
      }


    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
      return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureUser = getDataUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Data User'),
      ),

      body: FutureBuilder<List<DataUser>?>(
          future: futureUser, builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator(color: Colors.purple,),);
            }else if (snapshot.hasError){
              return Center(child: Text('Error : ${snapshot.error}'));
            }else if (!snapshot.hasData || snapshot.data!.isEmpty){
              return const Center(child: Text('No User Data Found'));
            }else{
              List<DataUser> dataUser = snapshot.data!;

              return ListView.builder(
                itemCount: dataUser.length,
                itemBuilder: (context, index){
                  final data = dataUser[index];
                  return Padding(
                    padding: EdgeInsets.all(8),
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(padding: EdgeInsets.all(5),
                            //widget gambar
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                data.avatar ?? "",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                              ),
                            ),
                          ),

                          ListTile(
                            title: Text(
                              '${data.firstName} ${data.lastName}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                              ),
                            ),
                            subtitle: Text(data.email ?? '_'),
                          )

                          //Task : untuk membuat page detail
                          //kirim ke group wa --> demo list dan detail user (gambar, full name, email)
                          //maksimal jam 5 sore
                        ],
                      ),
                    ),
                  );
                },
              );
            }
      }),
    );
  }
}
