#include <napi.h>
#include "bindings.h"

class PrngObject : public Napi::ObjectWrap<PrngObject> {
 public:
  static Napi::Object Init(Napi::Env env, Napi::Object exports) {
    Napi::HandleScope scope(env);

    Napi::Function func = DefineClass(env, "PrngObject", {
        InstanceMethod("getInteger", &PrngObject::getInteger),
        InstanceMethod("getFloat", &PrngObject::getFloat),
        InstanceMethod("destroy", &PrngObject::destroy)
    });

    constructor = Napi::Persistent(func);
    constructor.SuppressDestruct();

    exports.Set("PrngObject", func);
    return exports;
  }

  PrngObject(const Napi::CallbackInfo& info);

 private:
  static Napi::FunctionReference constructor;

  Napi::Value getInteger(const Napi::CallbackInfo& info);
  Napi::Value getFloat(const Napi::CallbackInfo& info);
  void destroy(const Napi::CallbackInfo& info);

  PRNG *prng;
};

Napi::FunctionReference PrngObject::constructor;

PrngObject::PrngObject(const Napi::CallbackInfo& info) : Napi::ObjectWrap<PrngObject>(info)  {
  Napi::Env env = info.Env();
  Napi::HandleScope scope(env);

  int length = info.Length();

  if (length <= 0 || !info[0].IsNumber()) {
    Napi::TypeError::New(env, "Number expected").ThrowAsJavaScriptException();
  }

  Napi::Number value = info[0].As<Napi::Number>();
  this->prng = prng_new(value.Uint32Value());
}

Napi::Value PrngObject::getInteger(const Napi::CallbackInfo& info) {
  uint64_t next = next_unsigned_integer(this->prng);

  return Napi::Number::New(info.Env(), next);
}

Napi::Value PrngObject::getFloat(const Napi::CallbackInfo& info) {
  float next = next_unsigned_float(this->prng);

  return Napi::Number::New(info.Env(), next);
}

void PrngObject::destroy(const Napi::CallbackInfo& info) {
  prng_destroy(this->prng);
}

Napi::Object InitAll(Napi::Env env, Napi::Object exports) {
  return PrngObject::Init(env, exports);
}

NODE_API_MODULE(addon, InitAll)