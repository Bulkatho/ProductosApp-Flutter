import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:productos_app/providers/product_form_provider.dart';
import 'package:productos_app/services/services.dart';
import 'package:productos_app/ui/input_decorations.dart';
import 'package:productos_app/widgets/widgets.dart';
import 'package:provider/provider.dart';


class ProductPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    
    final productsService = Provider.of<ProductsService>(context);

    return ChangeNotifierProvider(
      create: (_) => ProductFormProvider(productsService.selectedProduct!),
      child: _ProductsPageBody(productsService: productsService)
    );
  }
}

class _ProductsPageBody extends StatelessWidget {
  const _ProductsPageBody({
    Key? key,
    required this.productsService,
  }) : super(key: key);

  final ProductsService productsService;

  @override
  Widget build(BuildContext context) {

    final productForm = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        //keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [

            Stack(
              children: [
                ProductImage(url: productsService.selectedProduct?.picture),
                Positioned(
                  top: 60,
                  left: 20,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_outlined, size: 40, color: Colors.white),
                  )
                ),
                Positioned(
                  top: 60,
                  right: 30,
                  child: IconButton(
                    onPressed: () {
                      //TODO Camara o galeria.
                    },
                    icon: const Icon(Icons.camera_alt_outlined, size: 40, color: Colors.white),
                  )
                ),
              ],
            ),
            _ProductForm(),

            const SizedBox(height: 100),

          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save_outlined),
        onPressed: () async{
          if(!productForm.isValidForm()) return;

          await productsService.saveOrCreateProduct(productForm.product);
        },
      ),
   );
  }
}

class _ProductForm extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final productForm = Provider.of<ProductFormProvider>(context);
    final product = productForm.product;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        //height: 200,
        decoration: _buildBoxDecoration(),
        child: Form(
          key: productForm.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [

              const SizedBox(height: 10),
              
              TextFormField(
                decoration: InputDecorations.authInputDecoration(
                  hintText: 'Nombre del producto', 
                  labelText: 'Nombre'
                ),
                initialValue: product.name,
                onChanged: (value) => product.name = value,
                validator: (value) {
                  if(value == null || value.length <1)
                    return 'El nombre es obligatorio';
                },
              ),
              
              const SizedBox(height: 30),
              
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecorations.authInputDecoration(
                  hintText: '\$150', 
                  labelText: 'Precio: '
                ),
                initialValue: '${product.price}',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))
                ],
                onChanged: (value) {
                  if(double.tryParse(value) == null){
                    product.price = 0;
                  } else {
                    product.price = double.parse(value);
                  }
                },
              ),

              const SizedBox(height: 30),

              SwitchListTile.adaptive(
                title: const Text('Disponible'),
                activeColor: Colors.indigo,
                value: product.available,
                onChanged: (value){
                  productForm.updateAvailability(value);
                }
              ),

              const SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        offset: Offset(0,5),
        blurRadius: 5,
      )
    ]
  );
}